const { onCall, HttpsError } = require('firebase-functions/v2/https');
const axios = require('axios');

exports.chatTutor = onCall(
  {
    region: 'us-central1',
    timeoutSeconds: 120,
    memory: '256Mi',
  },
  async (request) => {
    console.log('Dados recebidos:', JSON.stringify(request.data));

    const apiKey = process.env.OPENROUTER_API_KEY;

    console.log('Usando API Key:', apiKey ? 'Presente' : 'Ausente');

    if (!apiKey) {
      throw new HttpsError('internal', 'Chave da API OpenRouter não configurada');
    }

    const message = request.data.message;
    const userId = request.data.userId;
    const model = 'deepseek/deepseek-chat:free';

    try {
      const response = await axios.post(
        'https://openrouter.ai/api/v1/chat/completions',
        {
          messages: [{ role: 'user', content: message }],
          model: model,
        },
        {
          headers: {
            Authorization: `Bearer ${apiKey}`,
            'Content-Type': 'application/json',
          },
          timeout: 60000,
        }
      );

      const reply = response.data.choices[0]?.message?.content || 'Resposta não disponível';
      return { reply };
    } catch (error) {
      console.error(`Erro ao chamar OpenRouter (modelo: ${model}):`, {
        message: error.message,
        code: error.code,
        status: error.response?.status,
        response: error.response?.data,
      });

      if (error.response?.status === 401) {
        throw new HttpsError('internal', 'Chave da API OpenRouter inválida');
      }
      throw new HttpsError('internal', 'Erro ao processar a mensagem', error.message);
    }
  }
);
