import hre from "hardhat";

// Define the VestingSchedule type to match the contract's struct
type VestingSchedule = [
  totalAmount: bigint,
  startTime: bigint,
  cliffDuration: bigint,
  duration: bigint,
  releasedAmount: bigint,
  revocable: boolean,
  revoked: boolean
];

async function main() {
  // Deploy TestToken
  console.log("Deploying TestToken...");
  const testToken = await hre.viem.deployContract("TestToken");
  console.log("TestToken deployed to:", testToken.address);

  // Deploy TokenVesting
  console.log("\nDeploying TokenVesting...");
  const vesting = await hre.viem.deployContract("TokenVesting");
  console.log("TokenVesting deployed to:", vesting.address);

  // Setup vesting schedule
  const [owner, beneficiary] = await hre.viem.getWalletClients();
  const amount = 1000000n * 10n ** 18n; // 1 million tokens
  const oneDay = 86400n; // seconds in a day
  const oneMonth = oneDay * 30n;
  const sixMonths = oneMonth * 6n;

  console.log("\nSetting up vesting schedule...");

  // Approve tokens
  await testToken.write.approve([vesting.address, amount]);
  console.log("Approved tokens for vesting contract");

  // Create vesting schedule
  await vesting.write.createVestingSchedule([
    testToken.address, // token address
    beneficiary.account.address, // beneficiary address
    amount, // amount
    oneMonth, // cliff duration (1 month)
    sixMonths, // vesting duration (6 months)
    true, // revocable
  ]);
  console.log("Created vesting schedule");

  // Get vesting schedule details
  const schedule = (await vesting.read.getVestingSchedule([
    testToken.address,
    beneficiary.account.address,
  ])) as VestingSchedule;

  console.log("\nVesting Schedule Details:");
  console.log("Total Amount:", schedule[0]);
  console.log(
    "Start Time:",
    new Date(Number(schedule[1]) * 1000).toLocaleString()
  );
  console.log("Cliff Duration:", schedule[2], "seconds");
  console.log("Total Duration:", schedule[3], "seconds");
  console.log("Released Amount:", schedule[4]);
  console.log("Revocable:", schedule[5]);
  console.log("Revoked:", schedule[6]);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Unhandled error:", error);
    process.exit(1);
  });
