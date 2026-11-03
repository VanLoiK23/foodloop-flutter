/**
 * Script nạp dữ liệu mẫu lên Firebase Firestore cho dự án FoodLoop
 * Hoạt động tự động trên Node.js v18+ (không cần cài thêm package nào)
 * Sử dụng REST API Firebase Auth & Firestore chính thức
 */

const fs = require('fs');
const path = require('path');

// Đọc thông tin cấu hình từ .env nếu có
function loadEnv() {
  const envPath = path.join(__dirname, '..', '.env');
  const env = {
    PROJECT_ID: 'ux-ui-11-2026',
    API_KEY: 'AIzaSyBuqWjsuZ5xeEx8RdWbbHlyxIzhvSe8Gh8',
  };

  if (fs.existsSync(envPath)) {
    const lines = fs.readFileSync(envPath, 'utf8').split('\n');
    for (let line of lines) {
      line = line.trim();
      if (!line || line.startsWith('#')) continue;
      const [key, ...vals] = line.split('=');
      const val = vals.join('=').trim();
      if (key === 'EXPO_PUBLIC_FIREBASE_PROJECT_ID') env.PROJECT_ID = val;
      if (key === 'EXPO_PUBLIC_FIREBASE_API_KEY') env.API_KEY = val;
    }
  }
  return env;
}

const config = loadEnv();

// Chuyển đổi dữ liệu JS sang Firestore REST API Document format
function toFirestoreValue(val) {
  if (val === null || val === undefined) return { nullValue: null };
  if (typeof val === 'string') return { stringValue: val };
  if (typeof val === 'boolean') return { booleanValue: val };
  if (typeof val === 'number') {
    if (Number.isInteger(val)) return { integerValue: val.toString() };
    return { doubleValue: val };
  }
  if (Array.isArray(val)) {
    return {
      arrayValue: {
        values: val.map(toFirestoreValue),
      },
    };
  }
  if (typeof val === 'object') {
    const fields = {};
    for (const [k, v] of Object.entries(val)) {
      fields[k] = toFirestoreValue(v);
    }
    return { mapValue: { fields } };
  }
  return { stringValue: String(val) };
}

function toFirestoreFields(obj) {
  const fields = {};
  for (const [k, v] of Object.entries(obj)) {
    fields[k] = toFirestoreValue(v);
  }
  return { fields };
}

// 1. Lấy token xác thực ẩn danh
async function getAuthToken() {
  console.log('Đang đăng nhập ẩn danh vào Firebase...');
  const res = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${config.API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ returnSecureToken: true }),
    }
  );
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Đăng nhập thất bại: ${text}`);
  }
  const data = await res.json();
  console.log(`Đăng nhập thành công! User ID: ${data.localId}`);
  return { idToken: data.idToken, userId: data.localId };
}

// 2. Ghi 1 document lên Firestore
async function writeDocument(idToken, documentPath, data) {
  const url = `https://firestore.googleapis.com/v1/projects/${config.PROJECT_ID}/databases/(default)/documents/${documentPath}?key=${config.API_KEY}`;
  const res = await fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${idToken}`,
    },
    body: JSON.stringify(toFirestoreFields(data)),
  });

  if (!res.ok) {
    const err = await res.text();
    console.error(`Lỗi khi ghi ${documentPath}:`, err);
    return false;
  }
  return true;
}

// 3. Thực thi nạp toàn bộ dữ liệu
async function seedAll() {
  console.log(`====================================================`);
  console.log(`FOODLOOP FIREBASE DATA SEEDER`);
  console.log(`Project: ${config.PROJECT_ID}`);
  console.log(`====================================================\n`);

  const seedFilePath = path.join(__dirname, '..', 'assets', 'data', 'firebase_seed_data.json');
  if (!fs.existsSync(seedFilePath)) {
    throw new Error(`Không tìm thấy file dữ liệu mẫu: ${seedFilePath}`);
  }

  const seedData = JSON.parse(fs.readFileSync(seedFilePath, 'utf8'));
  const { idToken, userId } = await getAuthToken();

  let successCount = 0;

  // 1. Users
  console.log('-> Đang nạp collection [users]...');
  const user = seedData.users.default_user;
  await writeDocument(idToken, `users/default_user`, user);
  await writeDocument(idToken, `users/${userId}`, user);
  successCount += 2;

  // 2. User Notifications
  console.log('-> Đang nạp subcollection [users/{uid}/notify]...');
  for (const n of seedData.user_notifications) {
    await writeDocument(idToken, `users/default_user/notify/${n.id}`, n);
    await writeDocument(idToken, `users/${userId}/notify/${n.id}`, n);
    successCount += 2;
  }

  // 3. Settings
  console.log('-> Đang nạp collection [settings]...');
  const settings = seedData.settings.default_user;
  await writeDocument(idToken, `settings/default_user`, settings);
  await writeDocument(idToken, `settings/${userId}`, settings);
  successCount += 2;

  // 4. Spaces
  console.log('-> Đang nạp collection [spaces]...');
  for (const s of seedData.spaces) {
    await writeDocument(idToken, `spaces/${s.id}`, s);
    successCount++;
  }

  // 5. Products & Fridge Items
  console.log('-> Đang nạp collection [products] & [fridge_items]...');
  for (let i = 0; i < seedData.products.length; i++) {
    const p = seedData.products[i];
    await writeDocument(idToken, `products/product_${i + 1}`, p);
    successCount++;
  }
  for (let i = 0; i < seedData.fridge_items.length; i++) {
    const fi = seedData.fridge_items[i];
    await writeDocument(idToken, `fridge_items/item_${i + 1}`, fi);
    successCount++;
  }

  // Special products
  for (const [docId, p] of Object.entries(seedData.special_products)) {
    await writeDocument(idToken, `products/${docId}`, p);
    successCount++;
  }

  // 6. Members
  console.log('-> Đang nạp collection [members]...');
  for (let i = 0; i < seedData.members.length; i++) {
    await writeDocument(idToken, `members/member_${i + 1}`, seedData.members[i]);
    successCount++;
  }

  // 7. Invitations
  for (let i = 0; i < seedData.invitations.length; i++) {
    await writeDocument(idToken, `invitations/invite_${i + 1}`, seedData.invitations[i]);
    successCount++;
  }

  // 8. Food Posts & Requests (Bản đồ Radar Module 5)
  console.log('-> Đang nạp collection [food_posts] & [food_requests]...');
  for (const fp of seedData.food_posts) {
    await writeDocument(idToken, `food_posts/${fp.id}`, fp);
    successCount++;
  }
  for (let i = 0; i < seedData.food_requests.length; i++) {
    await writeDocument(idToken, `food_requests/req_${i + 1}`, seedData.food_requests[i]);
    successCount++;
  }

  // 9. Rescue Baskets & Orders (Chợ giải cứu Module 6 & 7)
  console.log('-> Đang nạp collection [rescue_baskets] & [rescue_orders]...');
  for (const b of seedData.rescue_baskets) {
    await writeDocument(idToken, `rescue_baskets/${b.id}`, b);
    successCount++;
  }
  for (let i = 0; i < seedData.rescue_orders.length; i++) {
    await writeDocument(idToken, `rescue_orders/order_${i + 1}`, seedData.rescue_orders[i]);
    successCount++;
  }

  // 10. Reports & Appeals (Module 8 & 9)
  console.log('-> Đang nạp collection [reports] & [appeals]...');
  for (const r of seedData.reports) {
    await writeDocument(idToken, `reports/${r.code}`, r);
    successCount++;
  }
  for (const [docId, ap] of Object.entries(seedData.appeals)) {
    await writeDocument(idToken, `appeals/${docId}`, ap);
    successCount++;
  }

  // 11. Activities (Huy hiệu, Xu hướng, Vinh danh)
  console.log('-> Đang nạp collection [activities]...');
  await writeDocument(idToken, `activities/impact_trends`, seedData.activities.impact_trends);
  await writeDocument(idToken, `activities/received_thanks`, seedData.activities.received_thanks);
  await writeDocument(idToken, `activities/honor_card`, seedData.activities.honor_card);
  successCount += 3;

  for (let i = 0; i < seedData.activities.achievements.length; i++) {
    await writeDocument(idToken, `activities/badge_${i + 1}`, seedData.activities.achievements[i]);
    successCount++;
  }

  console.log(`\n====================================================`);
  console.log(`HOÀN TẤT! Đã nạp thành công ${successCount} documents lên Firebase Firestore.`);
  console.log(`Mọi màn hình trên ứng dụng FoodLoop giờ đã có đầy đủ dữ liệu thật!`);
  console.log(`====================================================\n`);
}

seedAll().catch((err) => {
  console.error('Lỗi khi nạp dữ liệu:', err);
  process.exit(1);
});

