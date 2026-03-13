pipeline {
    agent any

    environment {
        SONAR_TOKEN  = credentials('sonar-token')
        IMAGE_NAME   = 'my-python-flask-app'
        SONAR_HOST   = 'http://3.7.36.157:9000'
    }

    stages {

        // ─── STAGE 1: Checkout ───
        stage('Checkout') {
            steps {
                echo '>>> Pulling latest source code...'
                git branch: 'main',
                    url: 'https://github.com/AakashReddyB/mypythonproject.git'
            }
        }

        // ─── STAGE 2: Install Dependencies ───
        stage('Install Dependencies') {
            steps {
                echo '>>> Installing Python dependencies...'
                sh '''
                    pip3 install --break-system-packages -r requirements.txt
                '''
            }
        }

        // ─── STAGE 3: Run Tests + Coverage ───
        stage('Run Tests') {
            steps {
                echo '>>> Running unit tests with coverage...'
                sh '''
                    python3 -m pytest tests/ \
                        --cov=. \
                        --cov-report=xml:coverage.xml \
                        --cov-report=term
                '''
            }
        }

        // ─── STAGE 4: SonarQube Analysis ───
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

        // ─── STAGE 5: Quality Gate ───
        stage('Quality Gate') {
            steps {
                echo '>>> Waiting for SonarQube Quality Gate result...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // ─── STAGE 6: Build Docker Image ───
        stage('Build Docker Image') {
            steps {
                echo '>>> Building Docker image...'
                sh '''
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                '''
            }
        }

        // ─── STAGE 7: Deploy Application ───
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
            echo 'App        → http://3.7.36.157:5000'
            echo 'SonarQube  → http://3.7.36.157:9000'
            echo 'Jenkins    → http://3.7.36.157:8080'
        }
        failure {
            echo '❌ Pipeline failed! Check logs above.'
        }
        always {
            echo '>>> Pipeline finished.'
        }
    }
}
