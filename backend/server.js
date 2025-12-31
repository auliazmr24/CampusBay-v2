const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const session = require("express-session");
const bcrypt = require("bcrypt");
const cors = require("cors");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const app = express();
const PORT = 3000;

// Buat folder uploads jika belum ada
const uploadDir = "./uploads";
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
  console.log("✅ Folder uploads dibuat");
}

// MIDDLEWARE
app.use(
  cors({
    origin: true, // Izinkan semua origin untuk development
    credentials: true,
  })
);
app.use(express.json());
app.use("/uploads", express.static("uploads")); // Serve static files untuk gambar

// MULTER CONFIG - Upload Gambar
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    const uniqueName = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueName + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // Max 5MB
  fileFilter: (req, file, cb) => {
    console.log("📁 File info:", {
      fieldname: file.fieldname,
      originalname: file.originalname,
      mimetype: file.mimetype,
      size: file.size,
    });

    // Cek berdasarkan extension file
    const allowedExtensions = /\.(jpg|jpeg|png|gif|webp)$/i;
    const hasValidExtension = allowedExtensions.test(file.originalname);

    // Cek berdasarkan mimetype (lebih fleksibel)
    const allowedMimeTypes = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"];
    const hasValidMimeType = allowedMimeTypes.includes(file.mimetype) || file.mimetype.startsWith("image/");

    if (hasValidExtension || hasValidMimeType) {
      console.log("✅ File accepted");
      return cb(null, true);
    } else {
      console.log("❌ File rejected - Invalid type");
      cb(new Error(`File type not allowed: ${file.mimetype}. Only jpg, png, gif, webp allowed.`));
    }
  },
});

// SESSION CONFIG
app.use(
  session({
    secret: "campusbay-secret-key-2024",
    resave: false,
    saveUninitialized: false,
    cookie: {
      maxAge: 24 * 60 * 60 * 1000, // 24 jam
      httpOnly: true,
      secure: false,
    },
  })
);

// KONEKSI DATABASE
const db = new sqlite3.Database("./database.db", (err) => {
  if (err) {
    console.error("❌ Database error:", err.message);
  } else {
    console.log("✅ SQLite terhubung");
    initDatabase();
  }
});

// INIT DATABASE TABLES
function initDatabase() {
  // Tabel Users
  db.run(
    `
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      name TEXT NOT NULL,
      campus TEXT NOT NULL,
      major TEXT,
      year TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `,
    (err) => {
      if (err) console.error("Error creating users table:", err);
      else console.log("✅ Users table ready");
    }
  );

  // Tabel Products
  db.run(
    `
    CREATE TABLE IF NOT EXISTS products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      price INTEGER NOT NULL,
      category TEXT NOT NULL,
      description TEXT,
      condition TEXT,
      campus TEXT NOT NULL,
      image_url TEXT,
      is_sold BOOLEAN DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  `,
    (err) => {
      if (err) console.error("Error creating products table:", err);
      else console.log("✅ Products table ready");
    }
  );

  // Tabel Cart
  db.run(`CREATE TABLE IF NOT EXISTS cart (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    product_id INTEGER,
    quantity INTEGER DEFAULT 1,
    FOREIGN KEY(product_id) REFERENCES products(id)
  )`);

  // --- API CART ---
  // Get Cart items
  app.get("/api/cart/:userId", (req, res) => {
    const { userId } = req.params;
    const query = `
      SELECT cart.id, cart.quantity, products.title, products.price, products.image_url, products.campus 
      FROM cart 
      JOIN products ON cart.product_id = products.id 
      WHERE cart.user_id = ?`;
    
    db.all(query, [userId], (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(rows);
    });
  });

  // Add to Cart
  app.post("/api/cart", (req, res) => {
    const { user_id, product_id } = req.body;
    db.run("INSERT INTO cart (user_id, product_id) VALUES (?, ?)", [user_id, product_id], function(err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true, id: this.lastID });
    });
  });

  // Remove from Cart (Checkout/Delete)
  app.delete("/api/cart/:id", (req, res) => {
    db.run("DELETE FROM cart WHERE id = ?", [req.params.id], function(err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true });
    });
  });

}

// ============================================
// MIDDLEWARE: CHECK LOGIN
// ============================================
const requireAuth = (req, res, next) => {
  if (!req.session.userId) {
    return res.status(401).json({
      success: false,
      message: "Silakan login terlebih dahulu",
    });
  }
  next();
};

// ============================================
// AUTH ROUTES
// ============================================

// TEST ENDPOINT
app.get("/", (req, res) => {
  res.json({
    message: "🚀 CampusBay Backend API",
    version: "1.0.0",
    status: "running",
  });
});

app.get("/api", (req, res) => {
  res.json({
    message: "🚀 CampusBay Backend API",
    version: "1.0.0",
    status: "running",
  });
});

// REGISTER
app.post("/api/auth/register", async (req, res) => {
  try {
    const { email, password, name, campus, major, year } = req.body;

    // Validasi input
    if (!email || !password || !name || !campus) {
      return res.status(400).json({
        success: false,
        message: "Email, password, nama, dan kampus wajib diisi",
      });
    }

    // Validasi email kampus (.ac.id)
    if (!email.endsWith(".ac.id")) {
      return res.status(400).json({
        success: false,
        message: "Harus menggunakan email kampus (.ac.id)",
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert ke database
    db.run(
      `INSERT INTO users (email, password, name, campus, major, year) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [email, hashedPassword, name, campus, major, year],
      function (err) {
        if (err) {
          if (err.message.includes("UNIQUE")) {
            return res.status(400).json({
              success: false,
              message: "Email sudah terdaftar",
            });
          }
          return res.status(500).json({
            success: false,
            message: "Gagal registrasi",
          });
        }

        // Auto login setelah register
        req.session.userId = this.lastID;
        req.session.userEmail = email;
        req.session.userName = name;

        res.status(201).json({
          success: true,
          message: "Registrasi berhasil",
          user: {
            id: this.lastID,
            email,
            name,
            campus,
          },
        });
      }
    );
  } catch (error) {
    console.error("Register error:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
});

// LOGIN
app.post("/api/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email dan password wajib diisi",
      });
    }

    // Cari user
    db.get("SELECT * FROM users WHERE email = ?", [email], async (err, user) => {
      if (err) {
        return res.status(500).json({
          success: false,
          message: "Server error",
        });
      }

      if (!user) {
        return res.status(401).json({
          success: false,
          message: "Email atau password salah",
        });
      }

      // Cek password
      const isValidPassword = await bcrypt.compare(password, user.password);

      if (!isValidPassword) {
        return res.status(401).json({
          success: false,
          message: "Email atau password salah",
        });
      }

      // Simpan session
      req.session.userId = user.id;
      req.session.userEmail = user.email;
      req.session.userName = user.name;

      res.json({
        success: true,
        message: "Login berhasil",
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          campus: user.campus,
          major: user.major,
          year: user.year,
        },
      });
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
});

// LOGOUT
app.post("/api/auth/logout", (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.status(500).json({
        success: false,
        message: "Gagal logout",
      });
    }
    res.json({
      success: true,
      message: "Logout berhasil",
    });
  });
});

// GET CURRENT USER
app.get("/api/auth/me", requireAuth, (req, res) => {
  db.get("SELECT id, email, name, campus, major, year FROM users WHERE id = ?", [req.session.userId], (err, user) => {
    if (err || !user) {
      return res.status(404).json({
        success: false,
        message: "User tidak ditemukan",
      });
    }
    res.json({
      success: true,
      user,
    });
  });
});

// ============================================
// PRODUCT ROUTES
// ============================================

// GET ALL PRODUCTS (PUBLIC)
app.get("/api/products", (req, res) => {
  const { category, campus, search } = req.query;

  let query = `
    SELECT 
      p.*,
      u.name as seller_name,
      u.campus as seller_campus,
      u.major as seller_major
    FROM products p
    JOIN users u ON p.user_id = u.id
    WHERE p.is_sold = 0
  `;
  const params = [];

  if (category && category !== "Semua") {
    query += " AND p.category = ?";
    params.push(category);
  }

  if (campus) {
    query += " AND p.campus = ?";
    params.push(campus);
  }

  if (search) {
    query += " AND (p.title LIKE ? OR p.description LIKE ?)";
    params.push(`%${search}%`, `%${search}%`);
  }

  query += " ORDER BY p.created_at DESC";

  db.all(query, params, (err, products) => {
    if (err) {
      return res.status(500).json({
        success: false,
        message: "Gagal mengambil produk",
      });
    }
    res.json({
      success: true,
      products,
    });
  });
});

// GET PRODUCT BY ID
app.get("/api/products/:id", (req, res) => {
  const query = `
    SELECT 
      p.*,
      u.id as seller_id,
      u.name as seller_name,
      u.campus as seller_campus,
      u.major as seller_major,
      u.year as seller_year,
      u.email as seller_email
    FROM products p
    JOIN users u ON p.user_id = u.id
    WHERE p.id = ?
  `;

  db.get(query, [req.params.id], (err, product) => {
    if (err) {
      return res.status(500).json({
        success: false,
        message: "Server error",
      });
    }
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Produk tidak ditemukan",
      });
    }
    res.json({
      success: true,
      product,
    });
  });
});

// ADD PRODUCT (REQUIRE LOGIN) - DENGAN UPLOAD GAMBAR
app.post("/api/products", requireAuth, upload.single("image"), (req, res) => {
  const { title, price, category, description, condition, campus } = req.body;

  console.log("📝 Request body:", req.body);
  console.log("📷 Request file:", req.file);

  if (!title || !price || !category || !campus) {
    return res.status(400).json({
      success: false,
      message: "Judul, harga, kategori, dan kampus wajib diisi",
    });
  }

  // IMPORTANT: Dapatkan URL gambar jika ada file yang diupload
  const image_url = req.file ? `/uploads/${req.file.filename}` : null;

  console.log("🖼️ Image URL to save:", image_url);

  db.run(
    `INSERT INTO products (user_id, title, price, category, description, condition, campus, image_url) 
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [req.session.userId, title, price, category, description, condition, campus, image_url],
    function (err) {
      if (err) {
        console.error("❌ Database error:", err);
        return res.status(500).json({
          success: false,
          message: "Gagal menambahkan produk",
        });
      }

      console.log("✅ Product saved with ID:", this.lastID);

      res.status(201).json({
        success: true,
        message: "Produk berhasil ditambahkan",
        productId: this.lastID,
        image_url: image_url,
      });
    }
  );
});

// GET MY PRODUCTS (REQUIRE LOGIN)
app.get("/api/products/my/listings", requireAuth, (req, res) => {
  db.all("SELECT * FROM products WHERE user_id = ? ORDER BY created_at DESC", [req.session.userId], (err, products) => {
    if (err) {
      return res.status(500).json({
        success: false,
        message: "Gagal mengambil produk",
      });
    }
    res.json({
      success: true,
      products,
    });
  });
});

// UPDATE PRODUCT (REQUIRE LOGIN + OWNER)
app.put("/api/products/:id", requireAuth, upload.single("image"), (req, res) => {
  const { title, price, category, description, condition } = req.body;

  // Cek ownership
  db.get("SELECT user_id, image_url FROM products WHERE id = ?", [req.params.id], (err, product) => {
    if (err || !product) {
      return res.status(404).json({
        success: false,
        message: "Produk tidak ditemukan",
      });
    }

    if (product.user_id !== req.session.userId) {
      return res.status(403).json({
        success: false,
        message: "Anda tidak memiliki akses",
      });
    }

    // Jika ada gambar baru diupload
    let image_url = product.image_url;
    if (req.file) {
      // Hapus gambar lama jika ada
      if (product.image_url) {
        const oldImagePath = `.${product.image_url}`;
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath);
        }
      }
      image_url = `/uploads/${req.file.filename}`;
    }

    // Update
    db.run(
      `UPDATE products 
         SET title = ?, price = ?, category = ?, description = ?, condition = ?, image_url = ?
         WHERE id = ?`,
      [title, price, category, description, condition, image_url, req.params.id],
      function (err) {
        if (err) {
          return res.status(500).json({
            success: false,
            message: "Gagal update produk",
          });
        }
        res.json({
          success: true,
          message: "Produk berhasil diupdate",
          image_url: image_url,
        });
      }
    );
  });
});

// DELETE PRODUCT (REQUIRE LOGIN + OWNER)
app.delete("/api/products/:id", requireAuth, (req, res) => {
  // Cek ownership
  db.get("SELECT user_id, image_url FROM products WHERE id = ?", [req.params.id], (err, product) => {
    if (err || !product) {
      return res.status(404).json({
        success: false,
        message: "Produk tidak ditemukan",
      });
    }

    if (product.user_id !== req.session.userId) {
      return res.status(403).json({
        success: false,
        message: "Anda tidak memiliki akses",
      });
    }

    // Hapus gambar jika ada
    if (product.image_url) {
      const imagePath = `.${product.image_url}`;
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
    }

    // Delete
    db.run("DELETE FROM products WHERE id = ?", [req.params.id], function (err) {
      if (err) {
        return res.status(500).json({
          success: false,
          message: "Gagal menghapus produk",
        });
      }
      res.json({
        success: true,
        message: "Produk berhasil dihapus",
      });
    });
  });
});

// MARK AS SOLD
app.patch("/api/products/:id/sold", requireAuth, (req, res) => {
  db.get("SELECT user_id FROM products WHERE id = ?", [req.params.id], (err, product) => {
    if (err || !product) {
      return res.status(404).json({
        success: false,
        message: "Produk tidak ditemukan",
      });
    }

    if (product.user_id !== req.session.userId) {
      return res.status(403).json({
        success: false,
        message: "Anda tidak memiliki akses",
      });
    }

    db.run("UPDATE products SET is_sold = 1 WHERE id = ?", [req.params.id], function (err) {
      if (err) {
        return res.status(500).json({
          success: false,
          message: "Gagal update status",
        });
      }
      res.json({
        success: true,
        message: "Produk ditandai sebagai terjual",
      });
    });
  });
});

// ============================================
// SEED DATA (DEVELOPMENT ONLY)
// ============================================
app.get("/api/seed", async (req, res) => {
  try {
    // Hash password untuk dummy user
    const hashedPassword = await bcrypt.hash("password123", 10);

    // Insert dummy user
    db.run(
      `INSERT OR IGNORE INTO users (email, password, name, campus, major, year) 
       VALUES 
       ('budi@ui.ac.id', ?, 'Budi Santoso', 'Universitas Indonesia', 'Teknik Informatika', '2021'),
       ('siti@ugm.ac.id', ?, 'Siti Nurhaliza', 'Universitas Gadjah Mada', 'Sistem Informasi', '2022')`,
      [hashedPassword, hashedPassword],
      function (err) {
        if (err) {
          console.error("Seed users error:", err);
        }

        // Insert dummy products
        db.run(
          `INSERT INTO products (user_id, title, price, category, description, condition, campus) 
           VALUES 
           (1, 'Macbook Air M1 2020', 10500000, 'Elektronik', 'Fullset lengkap box, battery 90%', 'Bekas - Mulus', 'Universitas Indonesia'),
           (1, 'Buku Algoritma dan Pemrograman', 75000, 'Buku', 'Buku kuliah semester 1, kondisi bagus', 'Bekas', 'Universitas Indonesia'),
           (2, 'Kemeja Formal Biru', 50000, 'Fashion', 'Baru pakai 2x, masih mulus', 'Bekas - Mulus', 'Universitas Gadjah Mada')`,
          function (err) {
            if (err) {
              return res.status(500).json({
                success: false,
                message: "Seed error",
              });
            }
            res.json({
              success: true,
              message: "✅ Database seeded! Email: budi@ui.ac.id / siti@ugm.ac.id, Password: password123",
            });
          }
        );
      }
    );
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Seed error",
    });
  }
});

// START SERVER
app.listen(PORT, () => {
  console.log(`\n🚀 CampusBay Backend running on http://localhost:${PORT}`);
  console.log(`📡 API Endpoints:`);
  console.log(`   POST /api/auth/register - Daftar akun baru`);
  console.log(`   POST /api/auth/login - Login`);
  console.log(`   GET  /api/products - Lihat semua produk`);
  console.log(`   POST /api/products - Tambah produk (login required)`);
  console.log(`\n💡 Test: http://localhost:${PORT}/api/seed untuk isi data dummy\n`);
});

// Handle graceful shutdown
process.on("SIGINT", () => {
  db.close((err) => {
    if (err) {
      console.error(err.message);
    }
    console.log("\n👋 Database connection closed");
    process.exit(0);
  });
});
