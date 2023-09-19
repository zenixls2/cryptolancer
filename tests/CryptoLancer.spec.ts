import { Blockchain, SandboxContract } from "@ton-community/sandbox";
import { toNano, Address } from "ton-core";
import { CryptoLancer } from "../wrappers/CryptoLancer";
import { TestCoin } from "../wrappers/TestCoin";
import "@ton-community/test-utils";

describe("CryptoLancer", () => {
	let blockchain: Blockchain;
	let cryptoLancer: SandboxContract<CryptoLancer>;
	let token: SandboxContract<TestCoin>;
	let user = Address.parse(
		"EQDst9YSlIQZgO5SO4q7YmHXz8vAT-JBoPYxfjfET7JaoaVe"
	);

	beforeEach(async () => {
		blockchain = await Blockchain.create();
		cryptoLancer = blockchain.openContract(
			await CryptoLancer.fromInit(user)
		);
		token = blockchain.openContract(
			await TestCoin.fromInit(
				BigInt(30000),
				user,
				user,
				BigInt(300)
			)
		);

		const deployer = await blockchain.treasury("deployer");

		const deployResultToken = await token.send(
			deployer.getSender(),
			{
				value: toNano("0.05"),
			},
			{
				$$type: "Deploy",
				queryId: 0n,
			}
		);
		expect(deployResultToken.transactions).toHaveTransaction({
			from: deployer.address,
			to: token.address,
			deploy: true,
			success: true,
		});

		const deployResult = await cryptoLancer.send(
			deployer.getSender(),
			{
				value: toNano("0.05"),
			},
			{
				$$type: "Deploy",
				queryId: 0n,
			}
		);

		expect(deployResult.transactions).toHaveTransaction({
			from: deployer.address,
			to: cryptoLancer.address,
			deploy: true,
			success: true,
		});
	});

	it("should deploy", async () => {
		// the check is done inside beforeEach
		// blockchain and cryptoLancer are ready to use
	});

	it("should create records", async () => {
		const employee = await blockchain.treasury("employee");
		const employer = await blockchain.treasury("employer");
		const recordResult = await cryptoLancer.send(
			employee.getSender(),
			{
				value: toNano("0.05"),
			},
			{
				$$type: "Record",
				employer: employer.address,
				employee: employee.address,
				tokenAddress: token.address,
				value: BigInt(300),
				complete: false,
			}
		);
		expect(recordResult.transactions).toHaveTransaction({
			from: employee.address,
			to: cryptoLancer.address,
			success: true,
		});
	});

	// temporary remove the test since contract has changed
	/*it("should increase counter", async () => {
		const increaseTimes = 3;
		for (let i = 0; i < increaseTimes; i++) {
			console.log(`increase ${i + 1}/${increaseTimes}`);

			const increaser = await blockchain.treasury(
				"increaser" + i
			);

			const counterBefore = await cryptoLancer.getCounter();

			console.log("counter before increasing", counterBefore);

			const increaseBy = BigInt(
				Math.floor(Math.random() * 100)
			);

			console.log("increasing by", increaseBy);

			const increaseResult = await cryptoLancer.send(
				increaser.getSender(),
				{
					value: toNano("0.05"),
				},
				{
					$$type: "Add",
					queryId: 0n,
					amount: increaseBy,
				}
			);

			expect(increaseResult.transactions).toHaveTransaction({
				from: increaser.address,
				to: cryptoLancer.address,
				success: true,
			});

			const counterAfter = await cryptoLancer.getCounter();

			console.log("counter after increasing", counterAfter);

			expect(counterAfter).toBe(counterBefore + increaseBy);
		}
	});*/
});
