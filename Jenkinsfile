pipeline {
    agent any
    environment {
        SONAR_TOKEN = credentials('sonar-token')
        IMAGE_NAME  = 'my-python-flask-app'
        SONAR_HOST  = 'http://3.7.36.157:9000'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/AakashReddyB/mypythonproject.git'
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'pip3 install --break-system-packages -r requirements.txt'
            }
        }
        stage('Run Tests') {
            steps {
                sh 'python3 -m pytest tests/ --cov=. --cov-report=xml:coverage.xml'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                        sonar-scanner \
                            -Dsonar.projectKey=${IMAGE_NAME} \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=${SONAR_HOST} \
                            -Dsonar.token=${SONAR_TOKEN} \
                            -Dsonar.python.coverage.reportPaths=coverage.xml
                    """
                }
            }
        }
        stage('Build & Deploy') {
            steps {
                sh """
                    docker build -t ${IMAGE_NAME}:latest .
                    docker stop ${IMAGE_NAME} || true
                    docker rm   ${IMAGE_NAME} || true
                    docker run -d --name ${IMAGE_NAME} -p 5000:5000 ${IMAGE_NAME}:latest
                """
            }
        }
    }
    post {
        success { echo '✅ App running at http://3.7.36.157:5000' }
        failure { echo '❌ Pipeline failed — check the logs.' }
    }
}
