# hyperledger fabric chaincode 

## 0. hyperledfer fabric network set-up
- linux 기반의 ubuntu 18.04 설치
- Docker 설치
- curl 설치
- node.js 설치
- GO 설치
- python, git 설치(우분투에 기본적으로 설치되어 있음)
- hyperledger fabric image 및 sample 설치

## 1. 설치 방법
    Docker 설치
    sudo apt-get install docker.io
    sudo apt-get install docekr-compose
    sudo apt-get software-properties-common

    현재 사용자에게 권한 주기
    sudo usermod -aG docker $USER
    
    리부트하기
    sudo reboot
    
    리부팅 후 버전 확인
    docker version

    curl 설치
    sudo apt-get install curl

    node.js 설치
    sudo apt-getinstall build-essential libssl-dev
    curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh -o install_nvm.sh
    bash install_nvm.sh
    source ~/.profile
    nvm install v8.11

    GO 설치
    curl -O https://storage.googleapis.com/golang/go1.13.14.linux-amd64.tar.gz
    


## 1. 체인코드 작성 
    package main

    import (
        "encoding/json"
        "fmt"
        "strconv"

        "github.com/hyperledger/fabric/core/chaincode/shim"
        sc "github.com/hyperledger/fabric/protos/peer"
    )

    type SmartContract struct {
    }

    type UserRating struct {
        User string `json:"User"`
        Average float64 `json:"average"`
        Rates []Rate `json:"rates"`
    }
    type Rate struct {
        ProjectTitle string `json:"projecttitle"`
        Score float64 `json:"score"`
    }

    func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
        return shim.Success(nil)
    }

    func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc. Response {

        function, args := APIstub.GetFunctionAndParameters()

        if function == "addUser" {
            return s.addUser(APIstub, args)
        } else if function == "addRating" {
            return s.addRating(APIstub, args)
        } else if function == "readRating" {
            return s.readRating(APIstub, args)
        }
        return shim.Error("Invalid Smart Contract function name.")
    }

    func (s *SmartContract) addUser(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

        if len(args) != 1 {
            return shim.Error("fail!")
        }
        var user =UserRating{User: args[0], Average: 0}
        userAsBytes, _ := json.Marshal(user)
        APIstub.PutState(args[0], userAsBytes)

        return shim.Success([]byte("success"))
    }

    func (s *SmartContract) addRating(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
        if len(args) != 3 {
            return shim.Error("Incorrect number of arguments. Expcting 3")
        }
        userAsBytes, err := APIstub.GetState(args[0])
        if err != nil {
            jsonResp := "\"Error\":\"Failed to get state for "+ args[0]+"\"}"
            return shim.Error(jsonResp)
        } else if userAsBytes == nil{ //no state! error
        jsonResp := "\"Error\":\"User does not exist: "+ args[0]+"\"}"
        return shim.Error(jsonResp)
        }
        user := UserRating{}
        err = json.Unmarshal(userAsBytes, &user)
        if err != nil {
            return shim.Error(err.Error())
        }
        newRate, _ := strconv.ParseFloat(args[2],64)
        var Rate = Rate{ProjectTitle: args[1], Score: newRate}

        rateCount := float64(len(user.Rates))

        user.Rates=append(user.Rates, Rate)

        user.Average = (rateCount*user.Average+newRate)/(rateCount+1)

        userAsBytes, err = json.Marshal(user)

        APIstub.PutState(args[0], userAsBytes)

        return shim.Success([]byte("rating is updated"))

    }

    func (s *SmartContract) readRating(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

        if len(args) != 1 {
                return shim.Error("Incorrect number of arguments. Expecting 1")
        }

        userAsBytes, _ := APIstub.GetState(args[0])
        return shim.Success(userAsBytes)
    }

    func main() {

        err := shim.Start(new(SmartContract))
        if err != nil {
            fmt.Printf("Error creating new Smart Contract: %s", err)
        }
    }

## go build
    작성한 chaincode 파일(.go) compile

## shellscript 작성, 체인코드 설치, 배포 테스트
    #chaincode install
    docker exec cli peer chaincode install -n mysacc -v 1.0.0 -p github.com/mysacc

    #chaincode instantiate
    docker exec cli peer chaincode instantiate -n mysacc -v 1.0.0 -C mychannel -c '{"Args":["a","100"]}' -P 'OR ("Org1MSP.member", "Org2MSP.member", "Org3MSP.member")'
    sleep 5

    #chaincode query a
    docker exec cli peer chaincode query -n mysacc -C mychannel -c '{"Args":["get","a"]}'

    #chaincode invoke b
    docker exec cli peer chaincode invoke -n mysacc -C mychannel -c '{"Args":["set","c","250"]}'
    sleep 5

    #chaincode query b
    docker exec cli peer chaincode query -n mysacc -C mychannel -c '{"Args":["get","c"]}'

    echo

## 