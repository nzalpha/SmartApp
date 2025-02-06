
pipeline{
    agent{
        label 'workernode-1'
    }

    tools{
        maven 'mvn-3.8.8'
        jdk 'jdk-17'
    }
    environment {
        Application_Name = "eureka"
        Pom_Version = readMavenPom().getVersion()
        Pom_Packaging = readMavenPom().getPackaging()
        Docker_Hub = "docker.io/aadil08"
        Docker_Creds = credentials('docker_creds')
        
    }
    stages{
        stage ('Build'){
            // This will take care of building the application
            steps{
                echo "Building ${env.Application_Name} Application"
                // build using maven
                sh 'mvn clean package -DskipTests=true'
                archiveArtifacts artifacts: 'target/*.jar'
            }
        }

        /*stage ('Unit Tests'){
            steps {
                echo "Executing Unit Tests for ${env.Application_Name} App"
                sh 'mvn test'
            }
        } 
        */

        stage ('Docker Format'){
            // This is to format artifact
            steps{
                //install Pipeline Utility to use readMavenPOM
                //i27-eureka-0.0.1-SNAPSHOT.jar →> eureka-build number-branch name.jar
                echo "The actual format is ${env.Application_Name}-${env.Pom_Version}.${env.Pom_Packaging}"

                 // Expected ureka-buildnumber-branchname.jar to get build number in Jenkins goto Pipeline Syntax> Global Variables Reference

                 echo "Custom Format is ${env.Application_Name}-${BUILD_NUMBER}-${BRANCH_NAME}.${env.Pom_Packaging}"

            }
        }

        stage ('Docker Build & Push') {
            steps{
                echo "Starting Docker Build "
                sh """
                ls -la
                pwd
                echo "Copy the jar to the folder where Docker file is present"
                cp ${WORKSPACE}/target/i27-${env.Application_Name}-${env.Pom_Version}.${env.Pom_Packaging} ./.cicd/

                echo "********************* Building Docker Image ********************"
                docker build --force-rm  --no-cache --build-arg JAR_SRC=i27-${env.Application_Name}-${env.Pom_Version}.${env.Pom_Packaging}  -t ${env.Docker_Hub}/${env.Application_Name}:${GIT_COMMIT} ./.cicd
                docker images

                echo "********************* Login to Docker Repo ********************"
                docker login -u ${Docker_Creds_USR} -p ${Docker_Creds_PSW}

                echo "********************* Docker Push ********************"
                docker push ${env.Docker_Hub}/${env.Application_Name}:${GIT_COMMIT}

                """
            }
        }
    }
}