pipeline {
    environment {
        GIT_REPO = "https://github.com/comparexoss/cpx-oss2-workshop.git"
        ACR_LOGINSERVER = "hkkacrregistry.azure.io"
        ACR_REPO = 'mstrdevopsworkshop'
        //ACR_CRED = credentials('acr-credentials')   
        WEB_IMAGE="${env.ACR_LOGINSERVER}/${env.ACR_REPO}/rating-web"
        API_IMAGE="${env.ACR_LOGINSERVER}/${env.ACR_REPO}/rating-api"
        DB_IMAGE="${env.ACR_LOGINSERVER}/${env.ACR_REPO}/rating-db"
        
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
             dir('terraform')
             {
              script {
                    currentBuild.displayName = "${env.BUILD_NUMBER}"
                }
              sh 'terraform init -input=false'
              sh "terraform plan -input=false -out tfplan -var 'version=${env.BUILD_NUMBER}'"
              sh 'terraform show -no-color tfplan > tfplan.txt'
             }
        }
      }
      
       stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }

            steps {
                dir('terraform')
                {
                script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
                }
            }
        }
      
       stage('Apply') {
            steps {
                dir('terraform')
                {
                sh "terraform apply -input=false tfplan"
                }
            }
        }
  }
    
    post {
        always {
            archiveArtifacts artifacts: 'terraform/tfplan.txt'
        }
    }
}
