pipeline {
  agent {
    docker {
      image 'node:16'
      args '-u root:root'
    }
  }
  stages {
    stage('Verify Node') {
      steps {
        sh 'node -v'
        sh 'npm -v'
      }
    }
  }
}
