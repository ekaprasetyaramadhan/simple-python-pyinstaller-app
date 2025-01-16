node {
    def buildImage = 'python:2-alpine'
    def testImage = 'qnib/pytest'
    def deliverImage = 'cdrx/pyinstaller-linux:python2'

    properties([
        pipelineTriggers([
            pollSCM('H/2 * * * *')
        ])
    ])

    stage('Build') {
        docker.image(buildImage).inside {
            sh 'python -m py_compile simple-python-pyinstaller-app/sources/add2vals.py simple-python-pyinstaller-app/sources/calc.py'
        }
    }

    stage('Test') {
        docker.image(testImage).inside {
            try {
                sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
            } finally {
                junit 'test-reports/results.xml'
            }
        }
    }
}
