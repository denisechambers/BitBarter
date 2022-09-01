BitBarter - Neighborhood Jobs - Denise Chambers

 
The app, bitBarter, will provide a list of jobs that users can perform, such a yard work, painting, pet care,
babysitting, errand running. The jobs will be valued in a digital blockchain "currency" for a unit of time 
(probably hours) or possibly also distance as well for errands. The bitBarter relies on a list of jobs 
and resources with currency values, in order for users to have standardized services and 
ease of use of bitBarter. An escrow smart contract is envisioned to ensure customers pay up front 
for the work but the funds are escrowed in bitBarter. 
Once the customer has approved the work the provider can get payment.

Steps to get demo going :
1. Start Ganache. Add the project to ganache under contracts and save \n
2. Run commands in project root
3. truffle migrate --network test 
4. truffle console --network test
Once in the console type:
5. var accounts = await web3.eth.getAccounts()

6. var bb = await BitBarter.deployed()
7. bb.openJob("test","test",{from: accounts[0], value: 100000000000000000})
8. bb.acceptJob({from: accounts[1]})

9. optional: run below to see ETH transferred to contract. use address in openJobCall in the 'to' field
await web3.eth.getBalance('0xb76e4b06e43da4bee5d85825c4559dba3db347de')
-- this should return 100000000000000000

10. bb.jobIsDone({from: accounts[0]})
-- below provider gets paid
11. bb.getPaid({from: accounts[1]})
see account balances change in ganache accounts tab also by running \n

12. await web3.eth.getBalance(accounts[0])
13. await web3.eth.getBalance(accounts[1])

14. Run npm run dev in app folder

15. Open the web app in Chrome and open dev tools