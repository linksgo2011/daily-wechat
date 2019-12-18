pipeline{
    agent node
    triggers {
        pollSCM 'H/5 * * * *'
    }

   stages{
    stage('Test'){
        agent{
            label 'docker'
        }
        when{
            anyOf{
                branch "master";
                branch "release"
             }
             environment name: "RUN_TEST", value:"true"
             environment name: "IS_PROD", value:"false"
        }

        steps{
           script{
                try{
                        sh '''
                            chmod +x ./gradlew
                           ./gradlew clean test
                        '''
                }
           	finally{
                	junit keepLongStdio: true, testResults: "**/test-results/**/*.xml"
          	 }
        	}
           }
    },
    stage('Build'){
        agent{
            label 'docker'
        }
        when{
            anyOf{
                branch "master";
                branch "release"
             }
             environment name: "RUN_TEST", value:"true"
             environment name: "IS_PROD", value:"false"
        },
        environment:{
            DOCKER_CRED = credentials('docker')
        }

        steps{
            sh '''
                chmod +x ./gradlew
               ./gradlew build -x test
               ## TODO add commit id
               docker build -t linksgo2011/samples:daily-wechat-$GIT_COMMIT .
               docker push linksgo2011/samples:daily-wechat-$GIT_COMMIT
               docker rmi linksgo2011/samples:daily-wechat-$GIT_COMMIT
            '''
        }
    },
    stage('Deploy dev'){
            agent{
                label 'docker'
            }
            when{
                anyOf{
                    branch "master";
                    branch "release"
                 }
                 environment name: "RUN_TEST", value:"true"
                 environment name: "IS_PROD", value:"false"
            },
            environment:{
                DOCKER_CRED = credentials('docker')
                DOCKER_HOST = 'tcp://10.132.112.21:2376'
            }

            steps{
                sh '''
                    docker stack deploy -c docker-compose.yaml daily-wechat
                '''
            }
        },

        stage('Approve of Deploy PROD'){
                when{
                     branch "release"
                     environment name: "IS_PROD", value:"false"
                },
                steps{
                    input message: 'Deploy  to RPOD?'
                }
            },
        stage('Deploy PROD'){
                agent{
                    label 'docker'
                }
                when{
                     branch "release"
                     environment name: "IS_PROD", value:"false"
                },
                environment:{
                    // TODO
                    DOCKER_CRED = credentials('docker')
                    DOCKER_HOST = 'tcp://10.132.112.21:2376'
                }

                steps{
                    sh '''
                        docker stack deploy -c docker-compose.yaml sample-app
                    '''
                }
            }
   }
}

