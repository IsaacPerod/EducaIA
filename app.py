from flask import Flask, render_template, request, session, redirect
import sqlite3
import re
import os

app = Flask(__name__)
app.secret_key = 'sua_chave_secreta'  # Para sessões

# Conectar ao banco de dados
def init_db():
    db_path = 'db.sqlite'
    if os.path.exists(db_path):
        try:
            conn = sqlite3.connect(db_path)
            conn.close()
        except sqlite3.DatabaseError:
            os.remove(db_path)
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS usuarios 
                (id INTEGER PRIMARY KEY, username TEXT, pontos INTEGER)''')
    c.execute('''CREATE TABLE IF NOT EXISTS progresso 
                (user_id INTEGER, lesson_id INTEGER, concluida INTEGER)''')
    c.execute('''CREATE TABLE IF NOT EXISTS badges 
                (user_id INTEGER, badge_name TEXT)''')
    conn.commit()
    conn.close()

init_db()

# Função para gerar dicas
def get_dica(codigo, lesson_id):
    if lesson_id == 1:
        if '=' not in codigo:
            return "Dica: Use = para criar uma variável, como idade = 10."
        if not re.match(r'idade\s*=', codigo):
            return "Dica: A variável deve se chamar 'idade'."
    return "Tente revisar o exemplo da lição!"

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        conn = sqlite3.connect('db.sqlite')
        c = conn.cursor()
        c.execute("SELECT id, pontos FROM usuarios WHERE username = ?", (username,))
        user = c.fetchone()
        if user:
            session['user_id'] = user[0]
            session['pontos'] = user[1]
        else:
            c.execute("INSERT INTO usuarios (username, pontos) VALUES (?, 0)", (username,))
            conn.commit()
            c.execute("SELECT id FROM usuarios WHERE username = ?", (username,))
            session['user_id'] = c.fetchone()[0]
            session['pontos'] = 0
        conn.close()
        return redirect('/learn/1')
    return render_template('login.html')

@app.route('/learn/<int:lesson_id>', methods=['GET', 'POST'])
def learn(lesson_id):
    lessons = {
        1: {"title": "Variáveis", "content": "Variáveis guardam valores, como x = 5.", "challenge": "Crie uma variável 'idade' com sua idade."},
        2: {"title": "Condições", "content": "Use if/else para decisões.", "challenge": "Escreva um if que verifica se idade >= 18."}
    }
    lesson = lessons.get(lesson_id, lessons[1])
    
    pontos = session.get('pontos', 0)
    feedback = ""
    feedback_color = "green"
    dica = ""

    if request.method == 'POST':
        codigo = request.form['codigo']
        try:
            local_vars = {}
            exec(codigo, {}, local_vars)
            
            if lesson_id == 1 and 'idade' in local_vars:
                pontos += 20
                feedback = "Correto! Você criou a variável."
                conn = sqlite3.connect('db.sqlite')
                c = conn.cursor()
                c.execute("INSERT OR IGNORE INTO badges (user_id, badge_name) VALUES (?, ?)", 
                         (session['user_id'], "Primeira Variável"))
                conn.commit()
                conn.close()
                redirect('/learn/2')
            elif lesson_id == 2 and re.search(r'if\s+idade\s*>=?\s*18', codigo):
                pontos += 20
                feedback = "Boa! Condição correta."
            else:
                feedback = "Tente novamente."
                feedback_color = "red"
                dica = get_dica(codigo, lesson_id)
        except Exception as e:
            feedback = f"Erro: {str(e)}"
            feedback_color = "red"
            dica = get_dica(codigo, lesson_id)
        
        session['pontos'] = pontos

    return render_template('learn.html', lesson_id=lesson_id, lesson_title=lesson['title'], 
                          lesson_content=lesson['content'], challenge=lesson['challenge'], 
                          pontos=pontos, feedback=feedback, feedback_color=feedback_color, 
                          dica=dica)

@app.route('/progress')
def progress():
    conn = sqlite3.connect('db.sqlite')
    c = conn.cursor()
    c.execute("SELECT badge_name FROM badges WHERE user_id = ?", (session.get('user_id'),))
    badges = [row[0] for row in c.fetchall()]
    conn.close()
    return render_template('progress.html', badges=badges)

if __name__ == '__main__':
    app.run(debug=True)