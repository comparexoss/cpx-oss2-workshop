pipeline {
    environment {
        GIT_REPO = "https://github.com/comparexoss/cpx-oss2-workshop.git"
    }
  options { 
      disableConcurrentBuilds() 
      timestamps()
      
  }
   parameters {
        booleanParam(defaultValue: true, description: 'set true for automatic approve', name: 'autoApprove')
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
                playbook : 'playbooks/installprereqonbuildserver.yaml',
                become: true)
        }
      }
      stage('Plan AKS using terraform') {
          steps {   
            script {
                    currentBuild.displayName = "${version}"
                }
              sh 'terraform init -input=false'
              sh "terraform plan -input=false -out tfplan -var 'version=${version}'"
              sh 'terraform show -no-color tfplan > tfplan.txt'
        }
      }
      
       stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }

            steps {
                script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }
      
       stage('Apply') {
            steps {
                sh "terraform apply -input=false tfplan"
            }
        }
  }
    
    post {
        always {
            archiveArtifacts artifacts: 'tfplan.txt'
        }
    }
}
