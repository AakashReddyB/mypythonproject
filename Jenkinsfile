pipeline {
    agent any

    environment {
        SONAR_TOKEN  = credentials('sonar-token')
        IMAGE_NAME   = 'my-python-flask-app'
        SONAR_HOST   = 'http://sonarqube:9000'
    }

    stages {

        // ─── STAGE 1: Checkout ───
        stage('Checkout') {
            steps {
                echo '>>> Pulling latest source code...'
                checkout scm
            }
        }

        // ─── STAGE 2: Install Dependencies ───
        stage('Install Dependencies') {
            steps {
                echo '>>> Installing Python dependencies...'
                sh '''
                    pip install -r requirements.txt
                '''
            }
        }

        // ─── STAGE 3: Run Tests + Coverage ───
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
            post {
                always {
                    junit '**/test-results/*.xml'
                }
            }
        }

        // ─── STAGE 4: SonarQube Analysis ───
        stage('SonarQube Analysis') {
            steps {
                echo '>>> Running SonarQube code analysis...'
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

        // ─── STAGE 5: Build Docker Image ───
        stage('Build Docker Image') {
            steps {
                echo '>>> Building Docker image...'
                sh '''
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                '''
            }
        }

        // ─── STAGE 6: Deploy ───
        stage('Deploy') {
            steps {
                echo '>>> Deploying Flask application...'
                sh '''
                    docker stop ${IMAGE_NAME} || true
                    docker rm   ${IMAGE_NAME} || true
                    docker run -d \
                        --name ${IMAGE_NAME} \
                        --network devops-network \
                        -p 5000:5000 \
                        ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
            echo '   App        → http://localhost:5000'
            echo '   SonarQube  → http://localhost:9000'
            echo '   Jenkins    → http://localhost:8080'
        }
        failure {
            echo '❌ Pipeline failed! Check logs above.'
        }
        always {
            echo '>>> Pipeline finished.'
        }
    }
}
