node {
    // Environment variables
    def BUILD_IMAGE = 'python:3-alpine'  // Menggunakan Python 3
    def TEST_IMAGE = 'qnib/pytest'
    def DELIVER_IMAGE = 'cdrx/pyinstaller-linux:python3'  // Menggunakan PyInstaller untuk Python 3
    def AWS_EC2_IP = '54.254.128.133'  // Ganti dengan IP EC2 Anda
    def SSH_CREDENTIALS_ID = 'python-app-keypair'  // ID kredensial SSH
    def IMAGE_NAME = 'python-app'  // Nama image Docker

    try {
        stage('Checkout Code') {
            echo "Cloning repository..."
            checkout scm  // Mengkloning repository dari source control
        }

        stage('Build') {
            echo "Building application..."
            docker.image(BUILD_IMAGE).inside {
                sh 'python -m py_compile sources/add2vals.py sources/calc.py'
            }
        }

        stage('Test') {
            echo "Running tests..."
            docker.image(TEST_IMAGE).inside {
                try {
                    sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
                } finally {
                    junit 'test-reports/results.xml'  // Menghasilkan laporan pengujian JUnit
                }
            }
        }

        stage('Build Docker Image') {
            echo "Building Docker image..."
            docker.image('docker:20.10.12').inside {
                try {
                    sh """
                        docker build -t ${IMAGE_NAME}:latest .
                    """
                } catch (Exception e) {
                    echo "Docker image build failed!"
                    currentBuild.result = 'FAILURE'
                    throw e
                }
            }
        }

        stage('Push Docker Image to EC2') {
            echo "Pushing Docker image to EC2..."
            docker.image('docker:20.10.12').inside {
                withCredentials([sshUserPrivateKey(credentialsId: SSH_CREDENTIALS_ID, keyFileVariable: 'SSH_KEY')]) {
                    sh """
                        docker save ${IMAGE_NAME}:latest | ssh -i ${SSH_KEY} ubuntu@${AWS_EC2_IP} 'docker load'
                    """
                }
            }
        }

        stage('Manual Approval') {
            input message: 'Lanjutkan ke tahap Deploy?', ok: 'Proceed'
        }

        stage('Deploy to EC2') {
            echo "Deploying application on EC2..."
            withCredentials([sshUserPrivateKey(credentialsId: SSH_CREDENTIALS_ID, keyFileVariable: 'SSH_KEY')]) {
                sh """
                    ssh -i ${SSH_KEY} ubuntu@${AWS_EC2_IP} '
                    docker stop ${IMAGE_NAME} || true
                    docker rm ${IMAGE_NAME} || true
                    docker run -d --name ${IMAGE_NAME} -p 5000:5000 ${IMAGE_NAME}:latest
                    '
                """
            }
        }

        stage('Post-Deployment Wait') {
            echo "Application is running. Waiting for 1 minute before ending the pipeline..."
            sleep 60
        }

    } catch (Exception e) {
        echo "Pipeline failed: ${e.getMessage()}"
        currentBuild.result = 'FAILURE'
        throw e
    } finally {
        echo "Pipeline completed!"
    }
}
