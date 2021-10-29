const {shouldThrow} = require("./helpers/utils");
const NFCool = artifacts.require("NFCool");
const expect = require('chai').expect;

contract("NFCool", (accounts) => {
    let [owner, alice, bob] = accounts;
    let contract;

    beforeEach(async () => {
        contract = await NFCool.new({from: owner});
    });
    context("mint tokens", async () => {
       let ownerMints = [];
       const tokens = [
           {
               name: "AirMax 2020",
               uri: "testURI"
           },
           {
               name: "AirMax 2021",
               uri: "testURI2"
           }
       ];

        beforeEach(async() => {
            for (let i = 0 ; i < tokens.length ; i++) {
                ownerMints.push(await contract.mintToken(tokens[i].uri, tokens[i].name, web3.utils.asciiToHex(""), {from: owner}));
            }
        });

        it ("Should not throw an error if owner", () => {
            ownerMints.forEach(res => {
                expect(res.receipt.status).to.equal(true);
            });
        });

        it ("Should throw an error if not owner", async () => {
            await shouldThrow(contract.mintToken(tokens[0].uri, tokens[0].name, web3.utils.asciiToHex(""), {from: alice}));
        });

        it ("Should have expected uri", async () => {
            for (let i = 0 ; i < tokens.length ; i++) {
                const uri = (await contract.tokenData(i)).uri;
                expect(uri).to.equal(tokens[i].uri);
            }
        });

        it ("Should have expected name", async () => {
            for (let i = 0 ; i < tokens.length ; i++) {
                const name = (await contract.tokenData(i)).name;
                expect(name).to.equal(tokens[i].name);
            }
        });

        context ("Minting unit", async() => {
           let unitsMinted = [];
           let unitNfcIds = [];

            beforeEach(async () => {
                for (let i = 0 ; i < tokens ; i++) {
                    unitsMinted.push([]);
                    unitNfcIds.push([]);

                    for (let j = 0 ; j < 2 ; j++) {
                        let NFCId = (Math.random() % 9999).toString();
                        unitNfcIds[i].push(NFCId);
                        unitsMinted[i].push(await contract.mintTokenUnit(i, NFCId, web3.utils.asciiToHex(""), {from: owner}));
                    }
                }
            });

            it ("Should not Throw any error if owner", () => {
                for (let i = 0 ; i < tokens ; i++) {
                    for (let j = 0 ; j < 2 ; j++) {
                       expect(unitsMinted[i][j].receipt.status).to.equal(true);
                    }
                }
            });

            it ("Should throw an error if not owner", async () => {
                await shouldThrow(contract.mintTokenUnit(0, 'NFCId', web3.utils.asciiToHex(""), {from: alice}));
            })

            it ("Should have correct information stored", async () => {
                for (let i = 0 ; i < tokens ; i++) {
                    for (let j = 0 ; j < 2 ; j++) {
                        const res = await contract.tokenUnitData(i, j);
                        expect(res.status).to.equal('minted');
                        expect(res.uri).to.equal(unitNfcIds[i][j]);
                        expect(res.owner).to.equal(owner);
                    }
                }
            });
        });
    });
});
