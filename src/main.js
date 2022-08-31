import Web3 from 'web3'
import { newKitFromWeb3 } from '@celo/contractkit'
import BigNumber from "bignumber.js"
import cnsAbi from '../contract/cns.abi.json'
import erc20Abi from '../contract/erc20.abi.json'

// Most of the variables were left the same as the tutorial to make it easy to read

const ERC20_DECIMALS = 18

const MPContractAddress = "0x4410765AFFf01D0fcB9C1dBB9bfEb7F7619745ac" //The contract address on the blockchain

const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1" // The Contract address of the cUSD token

let kit

let contract

// The connect to celo wallet function remains the same 
const connectCeloWallet = async function () {
  if (window.celo) {
    try {
      notification("⚠️ Please approve this DApp to use it.")
      await window.celo.enable()
      notificationOff()
      const web3 = new Web3(window.celo)
      kit = newKitFromWeb3(web3)
      const accounts = await kit.web3.eth.getAccounts()
      kit.defaultAccount = accounts[0]
      contract = new kit.web3.eth.Contract(cnsAbi, MPContractAddress)
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
  } else {
    notification("⚠️ Please install the CeloExtensionWallet.")
  }
}

// This function gives permission/allowance for the cusd contract  to make use of a certain amount of its token in your wallet
async function approve(_price) {
  const cUSDContract = new kit.web3.eth.Contract(erc20Abi, cUSDContractAddress)
  const result = await cUSDContract.methods
    .approve(MPContractAddress, _price)
    .send({ from: kit.defaultAccount })
  return result
}


document.querySelector("#sendcelo").addEventListener("click", async(e)=> { // Runs the code written below once the send celo button in line 119 of the index.html file in pulic folder is triggered
  const shownamount = document.getElementById("amount").value // Get the value of the textfield called amount as it is wriiten in the modal of the send button 
  const amountSent = new BigNumber(shownamount).shiftedBy(ERC20_DECIMALS) //converts the amount written to a big number that will give us the equivalent of what we want to transfer in cUSD
  const receiver = document.getElementById("addressing").value //The the value of the address you want to send celo to
  notification("⌛ Waiting for approval to send money...")
  try{
    

    $('.modal').modal('close'); //Closes modal first so user can see the notification
    if(!Web3.utils.isAddress(receiver,44787)){
      notification(`⚠️ Invalid receiver address: ${receiver}.`);
      return;     
    }
    await approve(amountSent) //Run the approval code which will create a pop up for your celo wallet
      notification(`⌛ Sending `+ shownamount + ' cUSD to ' + receiver )
      try{
        const res = await contract.methods.sendToken(amountSent, receiver).send({ // Makes use of the send token function in our smart contract to send 
          from: kit.defaultAccount
        })
        notification(`You have succefully sent ` + shownamount + ` cUSD to ` + receiver)
        setTimeout(function(){
          notificationOff();
        }, 5000);
        getBalance();
        getName();
      }
      catch(error){
        notification(`⚠️ ${error}.`)
      }
  }
  catch(error){
    notification(`⚠️ ${error}.`)
  }
})

const getBalance = async function () { // This functions get the balance of my celo wallet
  const connectedWallet = await kit.defaultAccount

  document.querySelector("#wallAddress").textContent = connectedWallet
  const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
  const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2)
  document.querySelector("#balance").textContent = cUSDBalance
  document.querySelector("#balances").textContent = cUSDBalance
}

const getName = async function(){ //Pretty self explanatory function name, It gets the name assigned to the celo wallet if any 
  let _yourname = await contract.methods.userAddressLink(kit.defaultAccount).call()
  const noname = "You have not added a name"
  if(_yourname == ""){
    _yourname = noname
    document.querySelector("#nameButton").style.display = "block"
  }

  document.querySelector("#blockname").textContent = _yourname
}

// This ensure that at the click of the button submit button in line 107 in the index.html file which is 
// inside a modal, a function to get the wallet address is ran and inputted in the textfield on line 111 
const provideAddress = async function(){
  document.querySelector("#submitadd").addEventListener("click", async(e)=> {
    const usertag = document.getElementById("username").value
    const userAddress = await contract.methods.getUserViaUsername(usertag).call()
    document.querySelector("#addressing").textContent = userAddress
  }
  )
}

//Function to create a name for your wallet if you do not have any to yourself
const createName = async function(){
  document.querySelector('#submitName').addEventListener("click", async (e)=> {
    const chosenName = document.getElementById("getname").value
    if(chosenName === ""){
      notification(`⚠️ Username is empty : ${chosenName}.`)
      return;
    }
    notification(`⌛ Your new name will be  `+  chosenName )
    try{
      $('.modal').modal('close');
      await contract.methods.addUser(chosenName).send({
        from: kit.defaultAccount
      })
      notification(`🎉 You have succefully made ` + chosenName + ` your username, others can reach you with it  `)
        setTimeout(function(){
          notificationOff();
        }, 5000);
        getBalance();
        getName();
    }
    catch(error){
      notification(`⚠️ ${error}.`)
    }
  } )
} 


// Listener Functions

window.addEventListener('load', async () => {
  notification("⌛ Loading...")
  await connectCeloWallet()
  await getBalance()
  await getName()
  await provideAddress()
  await createName()
  notificationOff()
});


// FUNCTION TO MAKE NOTIFICATION SHOW 
function notification(_text) {
  document.querySelector(".noty").style.display = "block"
  document.querySelector("#notification").textContent = _text
}

// FUNCTION TO HIDE NOTIFICATION WITH CSS
function notificationOff() {
  document.querySelector(".noty").style.display = "none"
}
