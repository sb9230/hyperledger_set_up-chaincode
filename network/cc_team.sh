#chaincode install
docker exec cli peer chaincode install -n team -v 1.0.0 -p github.com/teamate
#chaincode instantiate
docker exec cli peer chaincode instantiate -n team -v 1.0.0 -C mychannel -c '{"Args":[]}' -P 'OR ("Org1MSP.member", "Org2MSP.member", "Org3MSP.member")'
sleep 5
#chaincode invoke user1 
docker exec cli peer chaincode invoke -n team -C mychannel -c '{"Args":["addUser","user1"]}'
sleep 5
#chaincode query user1
docker exec cli peer chaincode query -n team -C mychannel -c '{"Args":["readRating","user1"]}'

#chaincode invoke add rating
docker exec cli peer chaincode invoke -n team -C mychannel -c '{"Args":["addRating","user1","p1","5.0"]}'
sleep 5

echo