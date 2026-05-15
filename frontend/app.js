const connectWalletBtn = document.getElementById("connectWalletBtn");
const connectionStatus = document.getElementById("connectionStatus");
const walletAddress = document.getElementById("walletAddress");
const networkInfo = document.getElementById("networkInfo");

function shortenAddress(address) {
  if (!address) {
    return "-";
  }

  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

async function connectWallet() {
  if (!window.ethereum) {
    connectionStatus.textContent = "MetaMask not detected";
    alert("Please install MetaMask to connect your wallet.");
    return;
  }

  try {
    const provider = new ethers.BrowserProvider(window.ethereum);

    const accounts = await provider.send("eth_requestAccounts", []);
    const signer = await provider.getSigner();
    const network = await provider.getNetwork();

    const address = await signer.getAddress();

    connectionStatus.textContent = "Connected";
    walletAddress.textContent = shortenAddress(address);
    networkInfo.textContent = `Chain ID: ${network.chainId.toString()}`;

    connectWalletBtn.textContent = "Wallet Connected";

    console.log("Connected account:", accounts[0]);
  } catch (error) {
    console.error(error);
    connectionStatus.textContent = "Connection failed";
    alert("Wallet connection failed.");
  }
}

async function refreshWalletInfo() {
  if (!window.ethereum) {
    return;
  }

  try {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const accounts = await provider.send("eth_accounts", []);

    if (accounts.length === 0) {
      connectionStatus.textContent = "Not connected";
      walletAddress.textContent = "-";
      networkInfo.textContent = "-";
      connectWalletBtn.textContent = "Connect Wallet";
      return;
    }

    const network = await provider.getNetwork();

    connectionStatus.textContent = "Connected";
    walletAddress.textContent = shortenAddress(accounts[0]);
    networkInfo.textContent = `Chain ID: ${network.chainId.toString()}`;
    connectWalletBtn.textContent = "Wallet Connected";
  } catch (error) {
    console.error(error);
  }
}

connectWalletBtn.addEventListener("click", connectWallet);

if (window.ethereum) {
  window.ethereum.on("accountsChanged", refreshWalletInfo);
  window.ethereum.on("chainChanged", () => {
    window.location.reload();
  });

  refreshWalletInfo();
}