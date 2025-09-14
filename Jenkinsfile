pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'CI tulee, oletko valmis?''
            }
        }

    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}

