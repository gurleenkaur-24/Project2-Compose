/**
 * Jenkinsfile (Task 3)
 * - Builds & runs a simple container using DinD over TLS.
 * - Security integration:
 *    1) Least-privilege: run this pipeline as the non-admin 'pipeline' user you created.
 *       (No admin perms required: only Job Build/Read/Discover/Cancel + Run/View Read.)
 *    2) No secret leakage: all secret use (e.g., Docker Hub login) is wrapped in withCredentials and echo is sanitized.
 *    3) Safe Docker connection: uses TLS to 'docker' alias with client certs mounted read-only by Compose.
 */

pipeline {
  agent any
  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds() // avoids overlapping runs
    buildDiscarder(logRotator(numToKeepStr: '15')) // log retention hygiene
    skipDefaultCheckout(true) // we control checkout stage explicitly
  }

  environment {
    // Matches your Compose TLS setup (DinD alias + client certs)
    DOCKER_HOST = "tcp://docker:2376"
    DOCKER_TLS_VERIFY = "1"
    DOCKER_CERT_PATH = "/certs/client"
    // Optional flag to enable pushing to Docker Hub without editing file
    PUBLISH = "${params.PUBLISH ?: 'false'}"
  }

  parameters {
    booleanParam(name: 'PUBLISH', defaultValue: false, description: 'Push image to Docker Hub (requires credentials id "dockerhub")')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'echo "Checked out commit: $(git rev-parse --short HEAD)"'
      }
    }

    stage('Docker sanity (TLS)') {
      steps {
        sh '''
          set -e
          docker version
          docker info | head -n 20
        '''
      }
    }

    stage('Prepare Dockerfile (if missing)') {
      steps {
        sh '''
          if [ ! -f Dockerfile ]; then
            cat > Dockerfile <<'EOF'
FROM alpine:3.20
RUN echo "Hello from Task3 build at $(date)" > /hello.txt
CMD ["cat","/hello.txt"]
EOF
            echo "Created minimal Dockerfile."
          else
            echo "Using existing Dockerfile."
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

    stage('Run container (smoke test)') {
      steps {
        sh 'docker run --rm $(cat image.txt)'
      }
    }

    // Optional secure push — only runs when PUBLISH=true and credentials exist.
    stage('Push to Docker Hub (Optional, secured)') {
      when { expression { return env.PUBLISH?.toLowerCase() == 'true' } }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DHU', passwordVariable: 'DHP')]) {
          sh '''
            set -e
            IMAGE_LOCAL="$(cat image.txt)"
            IMAGE_REMOTE="${DHU}/task3-app:${BUILD_NUMBER}"

            # Avoid leaking the token: never echo $DHP and disable command echo during login
            set +x
            echo "$DHP" | docker login -u "$DHU" --password-stdin
            set -x

            docker tag "$IMAGE_LOCAL" "$IMAGE_REMOTE"
            docker push "$IMAGE_REMOTE"
            docker logout
          '''
        }
      }
    }
  }

  post {
    success { echo 'Build OK' }
    always {
      archiveArtifacts artifacts: 'Dockerfile,image.txt', onlyIfSuccessful: false
      echo 'Pipeline finished.'
    }
  }
}
