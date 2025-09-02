<!-- Reference:
https://github.com/othneildrew/Best-README-Template -->
<a name="readme-top"></a>


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h1><i>Decentralized Lottery Service</i></h1>


  
  <img src="Read_Me_Content/top_label.jpg" alt="top_label.jpg">
  .

  <p align="center">
    An ethereum smart contract to facilitate creation of custom lotteries & decentralized participation with a random winner-selection strategy !
  </p>
</div>
 
<br>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#built-with">Built With</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#license-or-author">License or Author</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<br>

<!-- ABOUT THE PROJECT -->
## About The Project
  An ethereum smart contract to facilitate a decentralized lottery system with support for lottery creation, voluntary (one-time) participation, maintaining participation history and random (and fair) winner selection

  #### Rules of the system
  1. A user creates a lottery instance (and participates with his/her contribution), also associating a result-eligibility timestamp
  2. Other users can participate in the (already created) lottery (at most once per lottery) with their own contribution
  3. Once the result-eligibility-timestamp is reached/exceeded, no new participations are allowed & the winner can be declared
  4. Winner declaration (can be triggered by anyone)
     - Randomly selected (at most once per lottery)
     - WinningAmount = MIN(2 * winner.contribution, lottery.value)
     - LotteryServiceOwnerProfit = lottery.value - WinningAmount

  #### Service Ownership rules
  1. Contract creator/deployer will be the initial-owner 
  2. Change in ownership is allowed (only by the current owner)
  3. Service-Profits must be spendable only by the current owner


  <p align="right">(<a href="#readme-top">back to top</a>)</p>

## Built With
  &nbsp; &nbsp; &nbsp; &nbsp; <img src="Read_Me_Content/Tech/Solidity.png" alt="Solidity_Logo" width="85"> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <img src="Read_Me_Content/Tech/nodejs.png" alt="NodeJS_Logo" width="75"> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <img src="Read_Me_Content/Tech/Ethereum.png" alt="Ethereum_Logo" width="85"> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <img src="Read_Me_Content/Tech/Remix.png" alt="Remix_Logo" width="85"> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <img src="Read_Me_Content/Tech/js.png" alt="JavaScript_Logo" width="80">

  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <b><i> Solidity </i></b> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <b><i> NodeJS </i></b> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <b><i> Ethereum </i></b> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <b><i> Remix </i></b> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <b><i> JavaScript </i></b>

  <p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started
  #### Prerequisites
  * Solidity
  * Ethereum Lightweight node
  * NodeJS
  * Dependencies (Configured in each application)
  * IDE - Remix (Preferred)
  * Minimum - 8GB RAM, Intel i5 CPU (or Equivalent)

  #### Setup & Use
  1. Zip the repo
  2. Go to Remix IDE & import the zip into a new workspace
  3. Go to contracts & compile the required contract
  4. Go to deploy section
  5. Test with Virtual Machine & test accounts in VM
  6. Connect ethereum wallet accounts to remix *(advised to use a separate wallet with small amount of ether)*
  7. Deploy to Ethereum mainnet and test
  8. Invite others to interact with the deployed contract (directly/indirectly)

  <p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- LICENSE -->
## License or Author
  * Uditya Laad

  <p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact
  <b>Uditya Laad</b> &nbsp; [@linkedin.com/in/uditya-laad-222680148](https://www.linkedin.com/in/uditya-laad-222680148/)
  
  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; [@github.com/udityalaad](https://github.com/udityalaad)
  
  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; udityalaad123@gmail.com

  <b>Project Link</b> &nbsp; [https://github.com/udityalaad/DecentralizedLotteryService](https://github.com/udityalaad/DecentralizedLotteryService)

  <p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments
  * [Open Source Stack, Openzeppelin](https://www.openzeppelin.com/open-source-stack)
  * [Remix Resources](https://remix-project.org/?lang=en)
  * [github.com/othneildrew/Best-README-Template/](https://github.com/othneildrew/Best-README-Template)
  * [Banner Template, Smart Contract, Adobe Stock](https://stock.adobe.com/search/images?k=smart+contract&asset_id=509043142)

  <p align="right">(<a href="#readme-top">back to top</a>)</p>
