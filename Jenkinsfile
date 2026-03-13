pipeline {
    agent any

    environment {
        SONAR_TOKEN  = credentials('sonar-token')
        IMAGE_NAME   = 'my-python-flask-app'
        SONAR_HOST   = 'http://13.234.17.245:9000'
    }

    stages {

        // ─── STAGE 1: Install Dependencies ───
        stage('Install Dependencies') {
            steps {
                echo '>>> Installing Python dependencies...'
                sh '''
                    pip install -r requirements.txt
                '''
            }
        }

        // ─── STAGE 2: Run Tests + Coverage ───
        stage('Run Tests') {
            steps {
                echo '>>> Running unit tests with coverage...'
                sh '''
                    pytest tests/ \
                        --cov=. \
                        --cov-report=xml:coverage.xml \
                        --cov-report=term
                '''
            }
        }

        // ─── STAGE 3: SonarQube Analysis ───
        stage('SonarQube Analysis') {
            steps {
                echo '>>> Running SonarQube code analysis...'
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                            -Dsonar.projectKey=my-python-flask-app \
                            -Dsonar.sources=. \
                            -Dsonar.exclusions=**/tests/**,**/__pycache__/** \
                            -Dsonar.host.url=${SONAR_HOST} \
                            -Dsonar.token=${SONAR_TOKEN} \
                            -Dsonar.python.coverage.reportPaths=coverage.xml \
                            -Dsonar.python.version=3.11
                    '''
                }
            }
        }

        // ─── STAGE 4: Build Docker Image ───
        stage('Build Docker Image') {
            steps {
                echo '>>> Building Docker image...'
                sh '''
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                '''
            }
        }

        // ─── STAGE 5: Deploy ───
        stage('Deploy') {
            steps {
                echo '>>> Deploying Flask application...'
                sh '''
                    docker stop ${IMAGE_NAME} || true
                    docker rm   ${IMAGE_NAME} || true
                    docker run -d \
                        --name ${IMAGE_NAME} \
                        -p 5000:5000 \
                        ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed! Check logs above.'
        }
        always {
            echo '>>> Pipeline finished.'
        }
    }
}
