import { API, createCollectIterator } from 'vk-io';
import sqlite3 from 'sqlite3';
import * as dotenv from 'dotenv'

dotenv.config({
    path: '../.env'
});

const db = new sqlite3.Database('messages.db');

const api = new API({
	token: process.env.SCRAPPER_VK_TOKEN
});

const iterator = createCollectIterator({
    api,
    method: 'messages.getHistory',
    params: {
        peer_id: process.env.SCRAPPER_PEER_ID,
    },    
    countPerRequest: process.env.SCRAPPER_BATCH_SIZE,
});


for await (const chunk of iterator) {
    for (const message of chunk.items) {
        db.run(
            "insert into messages values (?)",
            JSON.stringify(message)
        );
    }
    console.log(`Received ${chunk.received} of ${chunk.total} messages`);
}
