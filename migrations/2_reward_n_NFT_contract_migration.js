const Reward = artifacts.require("RewardContract");
const Token = artifacts.require("NFT");

module.exports = async function (deployer) {
  await deployer.deploy(Reward);
  await deployer.deploy(Token, "MetaDwarfs", "MTD");
  let tokenInstance = await Token.deployed();
  let rewardInstance = await Reward.deployed();
  console.log("|| MINT DWARF");
  await tokenInstance.mintDwarf(2, 5, 2, 1);
  console.log("|| MINT ITEM");
  await tokenInstance.mintItem(1, 1, 1, 1).then((res) => {
    console.log(res);
  })
  .catch((err) => {
    console.error(err);
  });
  console.log("test1");
  await tokenInstance
    .setRewardAdress(rewardInstance.address)
    .then((res) => {
      console.log(res);
      console.log("Reward Address Set");
    })
    .catch((err) => {
      console.error(err);
    });
  console.log("test2");
  var levelNumber = 8;
  console.log(levelNumber);
  await tokenInstance
  .addLevels(levelNumber)
  .then((res) => {
    console.log(res);
  })
  .catch((err) => {
    console.error(err);
  });
  await tokenInstance
  .returnLevel(0)
  .then((res) => {
    console.log(res.toNumber());
  })
  .catch((err) => {
    console.error(err);
  });
  await tokenInstance
  .requiredExpForNextLevel(8)
  .then((res) => {
    console.log(res.toNumber());
  })
  .catch((err) => {
    console.error(err);
  });
  await rewardInstance
    .approve(rewardInstance.address, 1000000)
    .then((res) => {
      console.log(res);
    })
    .catch((err) => {
      console.error(err);
    });
  console.log("test3");
  await rewardInstance
    .totalSupply()
    .then((res) => {
      console.log("test4");

      console.log(res);
    })
    .catch((err) => {
      console.log("test5");

      console.error(err);
    });
  // await rewardInstance.reward(rewardInstance.address,100).then((res) => {
  //   console.log(res.toNumber());
  // }).catch(err => {
  //   console.log(err);
  // });
  console.log("test6");

  
    await tokenInstance
    .mine(0)
    .then((res) => {
      console.log(res);
      console.log("test7");
    })
    .catch((err) => {
      console.error(err.data);
    });
    await tokenInstance
    .mine(0)
    .then((res) => {
      console.log(res);
      console.log("test7");
    })
    .catch((err) => {
      console.error(err.data);
    });
    await tokenInstance
    .mine(0)
    .then((res) => {
      console.log(res);
      console.log("test7");
    })
    .catch((err) => {
      console.error(err.data);
    });
    await tokenInstance
    .mine(0)
    .then((res) => {
      console.log(res);
      console.log("test7");
    })
    .catch((err) => {
      console.error(err.data);
    });
    
    await tokenInstance
    .getDwarfDetails(0)
    .then((res) => {
      console.log(res);
      console.log("test7");
    })
    .catch((err) => {
      console.error(err.data);
    });
    await tokenInstance
    .getItemDetails(1)
    .then((res) => {
      console.log(res);
      console.log("test7");
    })
    .catch((err) => {
      console.error(err.data);
    });
    await tokenInstance
    .addStatPoint(0)
    .then((res) => {
      console.log(res);
      console.log("test7");
    })
    .catch((err) => {
      console.error(err.data);
    });
  console.log("test8");
 
  console.log("TestSon");
};
