/**
 * Jenkinsfile — Task 3 (agent = Node 16)
 * Runs the pipeline inside a Node 16 Docker container built from JenkinsAgent.Dockerfile.
 * Safe defaults: no concurrent runs, log retention, and no secrets echoed.
 */

pipeline {
  agent {
    // Build and use the Node 16 agent defined in JenkinsAgent.Dockerfile
    dockerfile {
      filename 'JenkinsAgent.Dockerfile'
      // Keep the workspace when the container exits so artifacts/logs persist
      reuseNode true
      // You usually don't need extra args; add --user root if your repo needs root writes
      // args '--user root'
    }
  }

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '15'))
    skipDefaultCheckout(true)
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'echo "Checked out $(git rev-parse --short HEAD)"'
      }
    }

    stage('Node toolchain') {
      steps {
        sh 'node -v && npm -v'
      }
    }

    // These steps only run if package.json exists (works even if your repo isn’t a Node app)
    stage('Install deps') {
      when { expression { fileExists("package.json") } }
      steps {
        sh 'npm ci || npm install'
      }
    }

    stage('Test') {
      when { expression { fileExists("package.json") } }
      steps {
        sh 'npm test --if-present'
      }
    }

    stage('Build') {
      when { expression { fileExists("package.json") } }
      steps {
        sh 'npm run build --if-present'
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'package*.json,**/npm-debug.log', onlyIfSuccessful: false
      echo 'Pipeline finished.'
    }
  }
}
