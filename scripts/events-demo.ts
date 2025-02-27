import hre from "hardhat";
import { parseAbiItem } from "viem";
import type { Log } from "viem";

// Define the ABI for the event
const eventAbi = parseAbiItem("event NumberUpdated(uint256 newValue)");

async function main() {
  // Get the contract instance
  const contractAddress = "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512"; // Address from previous deployment
  const contract = await hre.viem.getContractAt(
    "DataTypesAndVisibility",
    contractAddress
  );
  const publicClient = await hre.viem.getPublicClient();

  console.log("Watching for NumberUpdated events...");

  // Create an event listener
  const unwatch = await publicClient.watchEvent({
    address: contractAddress,
    event: eventAbi,
    onLogs: (logs) => {
      const log = logs[0];
      console.log("New event:", {
        blockNumber: log.blockNumber,
        newValue: log.topics[1] ? BigInt(log.topics[1]) : undefined,
      });
    },
  });

  // Generate some events by updating numbers
  console.log("\nGenerating events by updating numbers...");
  for (let i = 1; i <= 3; i++) {
    const value = BigInt(i * 100);
    await contract.write.updateNumber([value]);
    console.log(`Updated number to ${value}`);
  }

  // Get past events
  console.log("\nReading past NumberUpdated events:");
  const pastLogs = await publicClient.getLogs({
    address: contractAddress,
    event: eventAbi,
    fromBlock: 0n,
  });

  pastLogs.forEach((log) => {
    console.log("Past event:", {
      blockNumber: log.blockNumber,
      newValue: log.topics[1] ? BigInt(log.topics[1]) : undefined,
    });
  });

  // Clean up the event listener
  unwatch();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
