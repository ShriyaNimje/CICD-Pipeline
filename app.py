from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return '''
    <html>
      <head>
        <title>CI/CD Pipeline</title>
        <style>
          body {
            background-color: #green; /* Light blue background */
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
          }
          h1 {
            color: #333;
          }
        </style>
      </head>
      <body>
        <h1>CI/CD Pipeline Created Successfully</h1>
      </body>
    </html>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
