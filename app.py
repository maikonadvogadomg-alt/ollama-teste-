from flask import Flask, render_template, request, jsonify
import requests
import json
from datetime import datetime

app = Flask(__name__)

# Configuração
OLLAMA_URL = "http://localhost:11434"
OLLAMA_MODEL = "llama2"

# Armazenar histórico
chat_history = []

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/chat', methods=['POST'])
def chat():
    """Endpoint para enviar mensagem e receber resposta"""
    try:
        data = request.json
        user_message = data.get('message', '').strip()
        
        if not user_message:
            return jsonify({'error': 'Mensagem vazia'}), 400
        
        # Adicionar mensagem do usuário ao histórico
        chat_history.append({
            'role': 'user',
            'content': user_message,
            'timestamp': datetime.now().isoformat()
        })
        
        # Construir contexto com histórico
        context = "\n".join([
            f"{msg['role']}: {msg['content']}" 
            for msg in chat_history[-5:]  # Últimas 5 mensagens
        ])
        
        # Enviar para Ollama
        response = requests.post(
            f"{OLLAMA_URL}/api/generate",
            json={
                'model': OLLAMA_MODEL,
                'prompt': context,
                'stream': False
            },
            timeout=300
        )
        
        if response.status_code != 200:
            return jsonify({'error': 'Erro ao conectar com Ollama'}), 500
        
        bot_response = response.json().get('response', 'Sem resposta')
        
        # Adicionar resposta ao histórico
        chat_history.append({
            'role': 'assistant',
            'content': bot_response,
            'timestamp': datetime.now().isoformat()
        })
        
        return jsonify({
            'response': bot_response,
            'success': True
        })
        
    except requests.exceptions.ConnectionError:
        return jsonify({'error': 'Ollama não está conectado'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/models', methods=['GET'])
def get_models():
    """Obter lista de modelos disponíveis"""
    try:
        response = requests.get(f"{OLLAMA_URL}/api/tags")
        if response.status_code == 200:
            models = response.json().get('models', [])
            return jsonify({
                'models': [m['name'] for m in models],
                'success': True
            })
        return jsonify({'error': 'Erro ao obter modelos'}), 500
    except:
        return jsonify({'error': 'Ollama não está conectado'}), 500

@app.route('/api/status', methods=['GET'])
def get_status():
    """Verificar status de conexão com Ollama"""
    try:
        response = requests.get(f"{OLLAMA_URL}/api/tags", timeout=5)
        if response.status_code == 200:
            return jsonify({
                'connected': True,
                'model': OLLAMA_MODEL,
                'message': 'Conectado com Ollama'
            })
    except:
        pass
    
    return jsonify({
        'connected': False,
        'model': OLLAMA_MODEL,
        'message': 'Ollama não está conectado'
    })

@app.route('/api/history', methods=['GET'])
def get_history():
    """Obter histórico de chat"""
    return jsonify({'history': chat_history})

@app.route('/api/clear', methods=['POST'])
def clear_history():
    """Limpar histórico"""
    global chat_history
    chat_history = []
    return jsonify({'success': True, 'message': 'Histórico limpo'})

@app.route('/api/change-model', methods=['POST'])
def change_model():
    """Mudar modelo"""
    global OLLAMA_MODEL
    data = request.json
    new_model = data.get('model', '').strip()
    
    if new_model:
        OLLAMA_MODEL = new_model
        return jsonify({
            'success': True,
            'message': f'Modelo alterado para {new_model}',
            'model': OLLAMA_MODEL
        })
    
    return jsonify({'error': 'Modelo inválido'}), 400

if __name__ == '__main__':
    print("🚀 Servidor Flask iniciando...")
    print("📍 Acesse: http://localhost:5000")
    print("🔗 Ollama URL: " + OLLAMA_URL)
    print("🤖 Modelo: " + OLLAMA_MODEL)
    app.run(debug=True, host='0.0.0.0', port=5000)
