node {
    // Environment variables
    def BUILD_IMAGE = 'python:2-alpine'
    def TEST_IMAGE = 'qnib/pytest'
    def DELIVER_IMAGE = 'cdrx/pyinstaller-linux:python2'
    def AWS_EC2_IP = '54.254.128.133'  // Ganti dengan IP EC2 Anda
    def SSH_CREDENTIALS_ID = 'python-app-keypair'  // ID kredensial SSH Anda
    def IMAGE_NAME = 'python-app'  // Nama image yang dibangun

    try {
        stage('Checkout Code') {
            echo "Cloning repository..."
            checkout scm // Mengkloning repository dari SCM
        }

        stage('Build') {
            echo "Building Python application..."
            docker.image(BUILD_IMAGE).inside {
                sh '''
                    ls -l sources  # Memastikan file add2vals.py ada
                    pip install pyinstaller
                    pyinstaller --onefile sources/add2vals.py
                '''
            }
        }

        stage('Test') {
            echo "Running tests..."
            docker.image(TEST_IMAGE).inside {
                try {
                    sh '''
                        py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py
                    '''
                } finally {
                    junit 'test-reports/results.xml'  // Menghasilkan laporan pengujian JUnit
                }
            }
        }

        stage('Build Docker Image') {
            echo "Building Docker image..."
            sh "docker build -t ${IMAGE_NAME}:latest ."
        }

        stage('Push Docker Image to EC2') {
            echo "Pushing Docker image to EC2..."
            withCredentials([sshUserPrivateKey(credentialsId: SSH_CREDENTIALS_ID, keyFileVariable: 'SSH_KEY')]) {
                sh """
                    docker save ${IMAGE_NAME}:latest | ssh -i ${SSH_KEY} ubuntu@${AWS_EC2_IP} 'docker load'
                """
            }
        }

        stage('Manual Approval') {
            input message: 'Lanjutkan ke tahap Deploy?', ok: 'Proceed', parameters: []
        }

        stage('Deploy to EC2') {
            echo "Deploying application on EC2..."
            withCredentials([sshUserPrivateKey(credentialsId: SSH_CREDENTIALS_ID, keyFileVariable: 'SSH_KEY')]) {
                sh """
                    ssh -i ${SSH_KEY} ubuntu@${AWS_EC2_IP} '
                    docker stop ${IMAGE_NAME} || true && \
                    docker rm ${IMAGE_NAME} || true && \
                    docker run -d --name ${IMAGE_NAME} -p 5000:5000 ${IMAGE_NAME}:latest
                    '
                """
            }
        }

        stage('Verify Deployment') {
            echo "Verifying the application on EC2..."
            withCredentials([sshUserPrivateKey(credentialsId: SSH_CREDENTIALS_ID, keyFileVariable: 'SSH_KEY')]) {
                sh """
                    ssh -i ${SSH_KEY} ubuntu@${AWS_EC2_IP} 'curl -s http://localhost:5000 || exit 1'
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
