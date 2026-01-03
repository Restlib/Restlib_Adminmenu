const { Client, Intents } = require('discord.js');

// --- AYARLAR ---
// NOT: Tokenini buraya tırnak içine yapıştır.
const BOT_TOKEN = "BotTokenBuraya"; 
const ADMIN_ROLE_ID = "AdminRoleIdBuraya";
const GUILD_ID = "SunucuIdBuraya"; 
const REPORT_CHANNEL_ID = "<REPORT_CHANNEL_ID>"; // Raporların gideceği kanal

const client = new Client({ intents: [Intents.FLAGS.GUILDS] });

let pendingBankRequests = {};
let pendingInventoryRequests = {}; 

client.once('ready', async () => {
    console.log(`^2[Bot] Giriş yapıldı: ${client.user.tag}^0`);
    
    const commands = [
        { name: 'clearinv', description: 'Oyuncunun envanterini siler', options: [{ name: 'id', description: 'Oyuncu ID', type: 'STRING', required: true }] },
        { name: 'bankkontrol', description: 'Oyuncunun parasını gösterir', options: [{ name: 'id', description: 'Oyuncu ID', type: 'STRING', required: true }] },
        { name: 'giveitem', description: 'Oyuncuya eşya verir', options: [{ name: 'id', description: 'Oyuncu ID', type: 'STRING', required: true }, { name: 'item', description: 'Eşya Kodu', type: 'STRING', required: true }, { name: 'amount', description: 'Miktar', type: 'INTEGER', required: true }] },
        { name: 'setjob', description: 'Oyuncuya meslek verir', options: [{ name: 'id', description: 'Oyuncu ID', type: 'STRING', required: true }, { name: 'job', description: 'Meslek Kodu', type: 'STRING', required: true }, { name: 'grade', description: 'Rütbe', type: 'INTEGER', required: true }] },
        { name: 'weather', description: 'Hava durumunu değiştirir', options: [{ name: 'type', description: 'Hava Tipi', type: 'STRING', required: true, choices: [{ name: 'Güneşli', value: 'EXTRASUNNY' }, { name: 'Yağmurlu', value: 'RAIN' }, { name: 'Gece', value: 'NIGHT' }, { name: 'Karlı', value: 'XMAS' }] }] },
        { name: 'duyuru', description: 'Tüm sunucuya kayan yazı geçer', options: [{ name: 'mesaj', description: 'Duyuru Metni', type: 'STRING', required: true }] },
        { name: 'durum', description: 'Sunucunun anlık aktiflik durumunu gösterir' },
        { name: 'ss', description: 'Oyuncunun ekran görüntüsünü alır', options: [{ name: 'id', description: 'Oyuncu ID', type: 'STRING', required: true }] },
        { name: 'kisiseluyari', description: 'Sadece belirtilen oyuncuya ekranda uyarı gösterir', options: [{ name: 'id', description: 'Oyuncu ID', type: 'STRING', required: true }, { name: 'mesaj', description: 'Uyarı Metni', type: 'STRING', required: true }] },
        
        { name: 'clothing', description: 'Oyuncuya kıyafet menüsü verir (Illenium/QB)', options: [{ name: 'id', description: 'Oyuncu ID', type: 'STRING', required: true }] },

        { name: 'oyuncuenvanter', description: 'Oyuncunun üzerindeki eşyaları listeler', options: [{ name: 'id', description: 'Oyuncu ID', type: 'STRING', required: true }] },

        { 
            name: 'troll', 
            description: 'Oyuncuya troll efekti uygular', 
            options: [
                { name: 'id', description: 'Oyuncu ID', type: 'STRING', required: true },
                { 
                    name: 'tip', 
                    description: 'Troll Tipi', 
                    type: 'STRING', 
                    required: true, 
                    choices: [
                        { name: 'Sarhoş Et', value: 'sarhos' },
                        { name: 'Yak (Kısa Süreli)', value: 'yan' },
                        { name: 'Dondur', value: 'dondur' },
                        { name: 'Havaya Uçur', value: 'ucur' },
                        { name: 'Köpek Saldırısı', value: 'dogattack' }
                    ] 
                }
            ] 
        }
    ];

    try {
        const guild = await client.guilds.fetch(GUILD_ID);
        if(guild) {
            await guild.commands.set(commands);
            console.log(`✅ Slash komutları güncellendi!`);
        }
    } catch (error) {
        console.error(`❌ Hata: ${error.message}`);
    }
});

on('Restlibadmin:Bot:ReceiveBankData', (targetId, name, cash, bank) => {
    const tId = String(targetId);
    if (pendingBankRequests[tId]) {
        const interaction = pendingBankRequests[tId];
        if (name) interaction.editReply({ content: `💳 **Banka Bilgileri** (ID: ${tId})\n👤 **İsim:** ${name}\n💵 **Nakit:** $${cash}\n🏦 **Banka:** $${bank}` });
        else interaction.editReply({ content: `❌ ID: ${tId} oyunda bulunamadı.` });
        delete pendingBankRequests[tId];
    }
});


on('Restlibadmin:Bot:SendReportToDiscord', async (src, name, msg, x, y, z) => {
    try {
        const channel = await client.channels.fetch(REPORT_CHANNEL_ID);
        if (channel) {
            const posX = x ? Math.round(x) : "0";
            const posY = y ? Math.round(y) : "0";
            const posZ = z ? Math.round(z) : "0";

            const reportContent = [
                `🔔 <@&${ADMIN_ROLE_ID}>`,
                `🚨 **YENİ YARDIM TALEBİ**`,
                `👤 **Oyuncu:** ${name} (ID: ${src})`,
                `💬 **Mesaj:** ${msg}`,
                `🕒 **Zaman:** ${new Date().toLocaleTimeString('tr-TR')}`,
                `\n⚠️ *Müdahale etmek için oyuna giriş yapın.*`
            ].join('\n');

            channel.send({ content: reportContent });
        }
    } catch (error) {
        console.error("Rapor gönderilirken hata oluştu:", error);
    }
});

let pendingScreenshotRequests = {};

on('Restlibadmin:Bot:ReceiveScreenshot', (targetId, name, url) => {
    const tId = String(targetId);
    if (pendingScreenshotRequests[tId]) {
        const interaction = pendingScreenshotRequests[tId];
        
        if (name && url) {
            interaction.editReply({
                content: `📸 **Ekran Görüntüsü Alındı**\n👤 **Oyuncu:** ${name} (ID: ${tId})\n🖼️ **Görüntü:**`,
                files: [url]
            }).catch(()=>{});
        } else {
            interaction.editReply({ content: `❌ ID: ${tId} bulunamadı veya ekran görüntüsü alınamadı.` }).catch(()=>{});
        }
        
        delete pendingScreenshotRequests[tId];
    }
});

on('Restlibadmin:Bot:ReceiveInventoryData', (targetId, name, inventoryString) => {
    const tId = String(targetId);
    if (pendingInventoryRequests[tId]) {
        const interaction = pendingInventoryRequests[tId];
        
        if (name) {
            
            let formattedInventory = "Envanter Boş";
            
            if (inventoryString && inventoryString !== "Envanter Boş.") {
                formattedInventory = inventoryString.split(', ').map(item => `🔹 ${item}`).join('\n');
            }

            if (formattedInventory.length > 1900) {
                formattedInventory = formattedInventory.substring(0, 1850) + "\n... (Liste çok uzun, devamı kesildi)";
            }

            const messageContent = [
                `🎒 **Oyuncu Envanteri** (ID: ${tId})`,
                `👤 **İsim:** ${name}`,
                `📦 **Eşyalar:**`,
                `${formattedInventory}`
            ].join('\n');

            interaction.editReply({ content: messageContent }).catch(()=>{});
        } else {
            interaction.editReply({ content: `❌ ID: ${tId} oyunda bulunamadı.` }).catch(()=>{});
        }
        
        delete pendingInventoryRequests[tId];
    }
});

let pendingStatusRequest = null;

on('Restlibadmin:Bot:ReceiveStatusData', (total, police, ems, mech) => {
    if (pendingStatusRequest) {
        const interaction = pendingStatusRequest;
        
        const messageContent = [
            `📊 **Sunucu Durum Bilgileri**`,
            `👥 **Aktif Oyuncu:** ${total}`,
            `👮 **Aktif Polis:** ${police}`,
            `🚑 **Aktif EMS:** ${ems}`,
            `🔧 **Aktif Mekanik:** ${mech}`,
            `🟢 **Sunucu Durumu:** Aktif`
        ].join('\n');

        interaction.editReply({ content: messageContent }).catch(()=>{});
        pendingStatusRequest = null;
    }
});

client.on('interactionCreate', async interaction => {
    if (!interaction.isCommand()) return;
    if (!interaction.member.roles.cache.has(ADMIN_ROLE_ID)) return interaction.reply({content: 'Yetkin yok!', ephemeral: true});

    const { commandName } = interaction;
    const targetId = interaction.options.getString('id'); 

    try {
        if (commandName === 'clearinv') {
            emit('Restlibadmin:Server:DiscordClearInv', targetId, interaction.user.username);
            await interaction.reply({ content: `🗑️ ID: ${targetId} envanteri siliniyor...`, ephemeral: false });
        }
        else if (commandName === 'bankkontrol') {
            await interaction.deferReply();
            pendingBankRequests[String(targetId)] = interaction;
            emit('Restlibadmin:Server:DiscordCheckBank', targetId);
        }
        else if (commandName === 'giveitem') {
            const item = interaction.options.getString('item');
            const amount = interaction.options.getInteger('amount');
            emit('Restlibadmin:Server:GiveItem', targetId, item, amount);
            await interaction.reply({ content: `🎁 Verildi: ${amount}x ${item} (ID: ${targetId})`, ephemeral: false });
        }
        else if (commandName === 'setjob') {
            const job = interaction.options.getString('job');
            const grade = interaction.options.getInteger('grade');
            emit('Restlibadmin:Server:SetJob', targetId, job, grade);
            await interaction.reply({ content: `💼 Meslek ayarlandı: ${job} (ID: ${targetId})`, ephemeral: false });
        }
        else if (commandName === 'weather') {
            const weatherType = interaction.options.getString('type');
            emit('Restlibadmin:Server:SetWeather', weatherType);
            await interaction.reply({ content: `🌤️ Hava durumu değiştirildi: ${weatherType}`, ephemeral: false });
        }
        else if (commandName === 'duyuru') {
            const msg = interaction.options.getString('mesaj');
            emit('Restlibadmin:Server:SendAnnounce', { type: 'global', msg: msg });
            await interaction.reply({ content: `📢 Genel duyuru gönderildi.`, ephemeral: false });
        }
        else if (commandName === 'kisiseluyari') {
            const msg = interaction.options.getString('mesaj');
            emit('Restlibadmin:Server:DiscordPersonalWarn', targetId, msg);
            await interaction.reply({ content: `⚠️ ID: ${targetId} oyuncusuna özel uyarı gönderildi.`, ephemeral: false });
        }
        else if (commandName === 'clothing') {
            emit('Restlibadmin:Server:OpenClothing', targetId);
            await interaction.reply({ content: `👕 ID: ${targetId} oyuncusuna kıyafet menüsü gönderildi.`, ephemeral: false });
        }
        else if (commandName === 'oyuncuenvanter') {
            await interaction.deferReply();
            pendingInventoryRequests[String(targetId)] = interaction;
            emit('Restlibadmin:Server:DiscordGetInventory', targetId);
        }
        else if (commandName === 'durum') {
            await interaction.deferReply();
            pendingStatusRequest = interaction;
            emit('Restlibadmin:Server:DiscordGetStatus');
        
            setTimeout(() => {
                if(pendingStatusRequest) {
                    interaction.editReply({ content: '❌ Sunucudan yanıt alınamadı.' }).catch(()=>{});
                    pendingStatusRequest = null;
                }
            }, 5000);
        }
        else if (commandName === 'ss') {
            await interaction.deferReply();
            pendingScreenshotRequests[String(targetId)] = interaction;
            emit('Restlibadmin:Server:DiscordTakeScreenshot', targetId);

            setTimeout(() => {
                if (pendingScreenshotRequests[String(targetId)]) {
                    interaction.editReply({ content: '❌ Sunucudan yanıt alınamadı (Zaman Aşımı).' }).catch(()=>{});
                    delete pendingScreenshotRequests[String(targetId)];
                }
            }, 10000);
        }
        else if (commandName === 'troll') {
            const trollType = interaction.options.getString('tip');
            emit('Restlibadmin:Server:TrollPlayer', targetId, trollType);
            
            const trollEmoji = {
                'sarhos': '🥴',
                'yan': '🔥',
                'dondur': '🧊',
                'ucur': '🚀',
                'dogattack': '🐕'
            };

            await interaction.reply({ 
                content: `${trollEmoji[trollType] || '🎭'} **Troll İşlemi:** ${trollType.toUpperCase()} (ID: ${targetId}) başarıyla uygulandı!`, 
                ephemeral: false 
            });
        }

    } catch (error) {
        console.error(error);
        if (interaction.deferred || interaction.replied) {
            await interaction.editReply({ content: 'İşlem sırasında bir hata oluştu.' }).catch(()=>{});
        } else {
            await interaction.reply({ content: 'Hata oluştu.', ephemeral: true }).catch(()=>{});
        }
    }
});

client.login(BOT_TOKEN);