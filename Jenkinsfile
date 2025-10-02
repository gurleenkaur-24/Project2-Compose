pipeline {
  agent {
    // Run all stages inside a Node 16 container
    docker { image 'node:16' }
  }
  options { timestamps() }
  stages {
    stage('Node version') {
      steps {
        sh 'node -v && npm -v'
      }
    }
  }
}
