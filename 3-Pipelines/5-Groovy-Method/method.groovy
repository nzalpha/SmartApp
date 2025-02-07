// Sample Example for Method


def printName(name, age) {
   return {
    echo "welcome Mr ${name}"
    echo "Your age is ${age}"
   }
}

pipeline {
    agent any
    stages{
        stage (" John stage"){
            steps{
                script{
                    printName('John','45').call()
                }
            }
        }

        stage (" Nz stage"){
            steps{
                script{
                    printName('Nz','35').call()
                }
            }
        }
    }
}