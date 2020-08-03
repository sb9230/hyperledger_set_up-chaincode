#chaincode install
docker exec cli peer chaincode install -n mysacc -v 1.0.2 -p github.com/mysacc
#chaincode instantiate
docker exec cli peer chaincode upgrade -n mysacc -v 1.0.2 -C mychannel -c '{"Args":["a","100"]}' -P 'OR ("Org1MSP.member", "Org2MSP.member", "Org3MSP.member")'
sleep 5
#chaincode query a
docker exec cli peer chaincode query -n mysacc -C mychannel -c '{"Args":["get","a"]}'
#chaincode invoke b
docker exec cli peer chaincode invoke -n mysacc -C mychannel -c '{"Args":["set","c","250"]}'
sleep 5
#chaincode query b
docker exec cli peer chaincode query -n mysacc -C mychannel -c '{"Args":["get","c"]}'

echo