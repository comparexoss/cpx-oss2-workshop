pipeline {
    environment {
        GIT_REPO = "https://github.com/comparexoss/cpx-oss2-workshop.git"
    }
  options { 
      disableConcurrentBuilds() 
      timestamps()
  }
  agent any
  stages {
      stage('Checkout') {
        steps {
            git url: "${env.GIT_REPO}", branch: 'master'
        }
      }
      stage('Prepare Build Server') {
          steps {   
          ansiblePlaybook( 
                playbook : 'playbooks/installprereq.yaml',
                become: true)
        }
      }
  }
}
