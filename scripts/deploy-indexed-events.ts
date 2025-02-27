import hre from "hardhat";
import { parseAbiItem, decodeEventLog } from "viem";

async function main() {
  const initialMessage = "Initial contract message";

  console.log("Deploying updated DataTypesAndVisibility contract...");

  const contract = await hre.viem.deployContract("DataTypesAndVisibility", [
    initialMessage,
  ]);

  console.log("Contract deployed to:", contract.address);

  // Define the event ABI
  const eventAbi = parseAbiItem(
    "event NumberUpdated(uint256 indexed newValue)"
  );

  // Set up event watching
  console.log("\nWatching for NumberUpdated events...");
  const publicClient = await hre.viem.getPublicClient();

  const unwatch = await publicClient.watchEvent({
    address: contract.address,
    event: eventAbi,
    onLogs: (logs) => {
      const log = logs[0];
      console.log("New event detected:", {
        blockNumber: log.blockNumber,
        newValue: log.topics[1] ? BigInt(log.topics[1]) : undefined,
      });
    },
  });

  // Generate some events
  console.log("\nGenerating events by updating numbers...");
  for (let i = 1; i <= 3; i++) {
    const value = BigInt(i * 100);
    const tx = await contract.write.updateNumber([value]);
    console.log(`Updated number to ${value}, transaction: ${tx}`);
  }

  // Get past events
  console.log("\nReading past NumberUpdated events:");
  const pastLogs = await publicClient.getLogs({
    address: contract.address,
    event: eventAbi,
    fromBlock: 0n,
  });

  pastLogs.forEach((log) => {
    console.log("Past event:", {
      blockNumber: log.blockNumber,
      newValue: log.topics[1] ? BigInt(log.topics[1]) : undefined,
    });
  });

  // Clean up
  unwatch();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
