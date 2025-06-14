const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
admin.initializeApp();

const API_KEY = functions.config().cloudconvert.key;

exports.onWordUpload = functions.storage
  .object()
  .onFinalize(async (object) => {
    const path = object.name;           // e.g. 'uploads/foo.docx'
    if (!path?.endsWith('.docx')) return;

    const bucket = admin.storage().bucket(object.bucket);
    const fileName = path.split('/').pop();
    const pdfName  = fileName.replace(/\.docx$/, '.pdf');

    // 1) Download the DOCX into memory
    const [buffer] = await bucket.file(path).download();

    // 2) Create a CloudConvert job
    const jobRes = await axios.post(
      'https://api.cloudconvert.com/v2/jobs',
      {
        tasks: {
          'import-1': { operation: 'import/upload' },
          'convert-1': {
            operation: 'convert',
            input: ['import-1'],
            input_format: 'docx',
            output_format: 'pdf'
          },
          'export-1': { operation: 'export/url', input: ['convert-1'] }
        }
      },
      { headers: { Authorization: `Bearer ${API_KEY}` } }
    );

    const importTask = jobRes.data.data.tasks.find(t => t.name === 'import-1');

    // 3) Upload the DOCX bytes to CloudConvert
    await axios.post(
      importTask.result.form.url,
      buffer,
      { headers: importTask.result.form.parameters.reduce((h, p) => (h[p.name]=p.value, h), {}) }
    );

    // 4) Poll until conversion is done
    let exportTask;
    do {
      await new Promise(r => setTimeout(r, 2000));
      const status = await axios.get(`https://api.cloudconvert.com/v2/jobs/${jobRes.data.data.id}`, {
        headers: { Authorization: `Bearer ${API_KEY}` }
      });
      exportTask = status.data.data.tasks.find(t => t.name==='export-1' && t.status==='finished');
    } while (!exportTask);

    const pdfUrl = exportTask.result.files[0].url;

    // 5) Download PDF and re-upload to Storage
    const pdfResp = await axios.get(pdfUrl, { responseType: 'arraybuffer' });
    await bucket.file(`converted/${pdfName}`).save(Buffer.from(pdfResp.data), {
      contentType: 'application/pdf'
    });
  });
