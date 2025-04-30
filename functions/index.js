const functions = require('firebase-functions');
const axios = require('axios');

exports.chatTutor = functions.https.onCall(async (data, context) => {
  try {
    const response = await axios.post(
      'https://api-inference.huggingface.co/models/mixtral-8x7b-instruct-v0.1',
      { inputs: data.message },
      {
        headers: {
          Authorization: `Bearer ${functions.config().huggingface.key}`,
          'Content-Type': 'application/json'
        }
      }
    );
    return { reply: response.data[0].generated_text };
  } catch (error) {
    throw new functions.https.HttpsError('internal', `Erro: ${error.message}`);
  }
});