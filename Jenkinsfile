pipeline {
  agent any
  options { timestamps(); ansiColor('xterm'); skipDefaultCheckout(true) }

  environment {
    // Match your Compose setup (DinD alias + TLS client certs)
    DOCKER_HOST = "tcp://docker:2376"
    DOCKER_TLS_VERIFY = "1"
    DOCKER_CERT_PATH = "/certs/client"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'echo "Checked out $(git rev-parse --short HEAD)"'
      }
    }

    stage('Docker sanity') {
      steps {
        sh '''
          set -e
          docker version
          docker info | head -n 20
        '''
      }
    }

    stage('Prepare Dockerfile if missing') {
      steps {
        sh '''
          if [ ! -f Dockerfile ]; then
            cat > Dockerfile <<'EOF'
FROM alpine:3.20
RUN echo "Hello from Jenkinsfile build at $(date)" > /hello.txt
CMD ["cat","/hello.txt"]
EOF
            echo "Created minimal Dockerfile (alpine)."
          else
            echo "Existing Dockerfile found."
          fi
          head -n 20 Dockerfile || true
        '''
      }
    }

    stage('Build image') {
      steps {
        sh '''
          set -e
          IMAGE="task3/app:${BUILD_NUMBER}"
          echo "$IMAGE" > image.txt
          docker build -t "$IMAGE" .
        '''
      }
    }

    stage('Run container') {
      steps {
        sh 'docker run --rm $(cat image.txt)'
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'Dockerfile,image.txt', onlyIfSuccessful: false
      echo 'Pipeline finished.'
    }
  }
}
