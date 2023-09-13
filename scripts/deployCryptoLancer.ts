import { toNano } from 'ton-core';
import { CryptoLancer } from '../wrappers/CryptoLancer';
import { NetworkProvider } from '@ton-community/blueprint';

export async function run(provider: NetworkProvider) {
    const cryptoLancer = provider.open(await CryptoLancer.fromInit(BigInt(Math.floor(Math.random() * 10000))));

    await cryptoLancer.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(cryptoLancer.address);

    console.log('ID', await cryptoLancer.getId());
}
