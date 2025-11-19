import { Pool, PoolClient } from 'pg';

// Configuration de la base de données PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://usilenzio_user:usilenzio_password_2024@postgres:5432/usilenzio',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Types pour les données
export interface Room {
  id: string;
  name: string;
  description: string;
  price: number;
  duration: number;
  max_people: number;
  objects_to_destroy: string[];
  included: string[];
  image_url?: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface Reservation {
  id: string;
  reservation_number: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  address?: string; // Adresse au format JSON
  room_name: string;
  date: string;
  time: string;
  duration: number;
  number_of_people: number;
  status: 'pending' | 'confirmed' | 'cancelled';
  amount: number;
  notes?: string;
  created_at: Date;
  updated_at: Date;
}

export interface HeaderConfig {
  id: string;
  site_name: string;
  logo_type: 'text' | 'image' | 'uploaded';
  logo_text: string;
  logo_image_url?: string;
  logo_alt_text: string;
  logo_uploaded_data?: Buffer;
  logo_uploaded_filename?: string;
  logo_uploaded_mimetype?: string;
  logo_uploaded_size?: number;
  created_at: Date;
  updated_at: Date;
}

export interface FooterConfig {
  id: string;
  site_name: string;
  site_description?: string;
  site_slogan?: string;
  contact_phone?: string;
  contact_email?: string;
  contact_address?: string;
  opening_hours_monday?: string;
  opening_hours_tuesday?: string;
  opening_hours_wednesday?: string;
  opening_hours_thursday?: string;
  opening_hours_friday?: string;
  opening_hours_saturday?: string;
  opening_hours_sunday?: string;
  cta_title?: string;
  cta_subtitle?: string;
  cta_button_text?: string;
  cta_button_url?: string;
  legal_links: any[];
  copyright_text?: string;
  created_at: Date;
  updated_at: Date;
}

export interface SmtpConfig {
  id: string;
  host: string;
  port: number;
  secure: boolean;
  username: string;
  password_encrypted: string;
  from_name: string;
  from_email: string;
  tls_reject_unauthorized: boolean;
  tls_min_version: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface Notification {
  id: string;
  type: string;
  recipient_email: string;
  recipient_name?: string;
  subject: string;
  message: string;
  status: 'pending' | 'sent' | 'failed';
  sent_at?: Date;
  error_message?: string;
  created_at: Date;
}

export interface Page {
  id: string;
  title: string;
  slug: string;
  content: string;
  meta_description?: string;
  seo_title?: string;
  keywords?: string[];
  is_published: boolean;
  created_at: Date;
  updated_at: Date;
}


export interface LegalPage {
  id: string;
  page_type: 'cgv' | 'privacy' | 'legal' | 'cookies';
  title: string;
  content: string;
  meta_description?: string;
  seo_title?: string;
  keywords?: string[];
  is_published: boolean;
  last_updated_by?: string;
  created_at: Date;
  updated_at: Date;
}

export interface HomepageSection {
  id: string;
  section_key: string;
  title?: string;
  subtitle?: string;
  content?: string;
  image_url?: string;
  video_url?: string;
  background_color?: string;
  text_color?: string;
  order_index: number;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface GlobalSection {
  id: string;
  section_key: string;
  section_name: string;
  title?: string;
  subtitle?: string;
  content?: string;
  image_url?: string;
  video_url?: string;
  background_color?: string;
  text_color?: string;
  order_index: number;
  is_active: boolean;
  page_identifier: string;
  created_at: Date;
  updated_at: Date;
}

export interface HomepageConfigItem {
  id: string;
  config_key: string;
  config_value: string;
  config_type: string;
  description?: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface HomepageConfig {
  site_title: string;
  site_description: string;
  site_name: string;
  contact_email: string;
  contact_phone: string;
  address: string;
  opening_hours: string;
  seo_keywords: string;
  seo_description: string;
  video_url?: string;
  site_url?: string;
  admin_email?: string;
  maintenance_mode?: boolean;
}

// Fonction utilitaire pour obtenir un client de la pool
export async function getClient(): Promise<PoolClient> {
  const client = await pool.connect();
  return client;
}

// Interface pour les données hebdomadaires
export interface WeeklyReservationsData {
  week: {
    start: string;
    end: string;
    startDate: Date;
    endDate: Date;
  };
  reservations: { [key: string]: Reservation[] };
  statistics: {
    total: number;
    confirmed: number;
    pending: number;
    cancelled: number;
    revenue: number;
  };
}

/**
 * Récupère les réservations d'une semaine spécifique
 */
export async function getWeeklyReservations(weekDate: Date): Promise<WeeklyReservationsData> {
  const client = await getClient();
  try {
    // Calculer le début et la fin de la semaine (lundi à dimanche)
    const startOfWeek = new Date(weekDate);
    const dayOfWeek = startOfWeek.getDay();
    const daysToMonday = dayOfWeek === 0 ? -6 : 1 - dayOfWeek; // Dimanche = 0, Lundi = 1
    startOfWeek.setDate(startOfWeek.getDate() + daysToMonday);
    startOfWeek.setHours(0, 0, 0, 0);

    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(endOfWeek.getDate() + 6);
    endOfWeek.setHours(23, 59, 59, 999);

    // Récupérer toutes les réservations de la semaine
    const startDate = startOfWeek.toISOString().split('T')[0];
    const endDate = endOfWeek.toISOString().split('T')[0];
    
    const result = await client.query(
      `SELECT 
        id,
        reservation_number,
        customer_name,
        customer_email,
        customer_phone,
        room_name,
        date,
        time_slot,
        duration,
        participants,
        status,
        amount,
        special_requests as notes,
        created_at,
        updated_at
      FROM reservations 
      WHERE DATE(date) >= $1 AND DATE(date) <= $2
      ORDER BY date ASC, time_slot ASC`,
      [startDate, endDate]
    );

    // Organiser les réservations par jour
    const reservationsByDay: { [key: string]: Reservation[] } = {};
    
    // Initialiser tous les jours de la semaine
    for (let i = 0; i < 7; i++) {
      const day = new Date(startOfWeek);
      day.setDate(day.getDate() + i);
      const dayKey = day.toISOString().split('T')[0];
      reservationsByDay[dayKey] = [];
    }

    // Répartir les réservations par jour
    result.rows.forEach((reservation: any) => {
      // Extraire la date au format YYYY-MM-DD
      const dayKey = new Date(reservation.date).toISOString().split('T')[0];
      if (reservationsByDay[dayKey]) {
        reservationsByDay[dayKey].push(reservation);
      }
    });

    // Calculer les statistiques de la semaine
    const totalReservations = result.rows.length;
    const confirmedReservations = result.rows.filter((r: any) => r.status === 'confirmed').length;
    const pendingReservations = result.rows.filter((r: any) => r.status === 'pending').length;
    const cancelledReservations = result.rows.filter((r: any) => r.status === 'cancelled').length;
    const totalRevenue = result.rows
      .filter((r: any) => r.status === 'confirmed')
      .reduce((sum: number, r: any) => {
        const amount = typeof r.amount === 'string' ? parseFloat(r.amount) : r.amount;
        return sum + (amount || 0);
      }, 0);

    return {
      week: {
        start: startOfWeek.toISOString().split('T')[0],
        end: endOfWeek.toISOString().split('T')[0],
        startDate: startOfWeek,
        endDate: endOfWeek
      },
      reservations: reservationsByDay,
      statistics: {
        total: totalReservations,
        confirmed: confirmedReservations,
        pending: pendingReservations,
        cancelled: cancelledReservations,
        revenue: totalRevenue
      }
    };

  } finally {
    client.release();
  }
}

// Gestion des salles
export async function getAllRooms(): Promise<Room[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM rooms WHERE is_active = true ORDER BY name'
    );
    return result.rows.map(row => ({
      ...row,
      objects_to_destroy: row.objects_to_destroy || [],
      included: row.included || []
    }));
  } finally {
    client.release();
  }
}

// Fonction pour l'administration - retourne toutes les salles (actives et inactives)
export async function getAllRoomsForAdmin(): Promise<Room[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM rooms ORDER BY name'
    );
    return result.rows.map(row => ({
      ...row,
      objects_to_destroy: row.objects_to_destroy || [],
      included: row.included || []
    }));
  } finally {
    client.release();
  }
}

export async function getRoomById(id: string): Promise<Room | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM rooms WHERE id = $1',
      [id]
    );
    if (result.rows.length === 0) return null;
    const row = result.rows[0];
    return {
      ...row,
      objects_to_destroy: row.objects_to_destroy || [],
      included: row.included || []
    };
  } finally {
    client.release();
  }
}

/**
 * Récupère une salle par son nom pour obtenir le prix
 * @param roomName - Nom de la salle
 * @returns Prix de la salle ou 0 si non trouvée
 */
export async function getRoomByName(roomName: string): Promise<Room | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM rooms WHERE name = $1 AND is_active = true',
      [roomName]
    );
    if (result.rows.length === 0) return null;
    const row = result.rows[0];
    return {
      ...row,
      objects_to_destroy: row.objects_to_destroy || [],
      included: row.included || []
    };
  } finally {
    client.release();
  }
}

/**
 * Crée une nouvelle salle avec un prix par défaut si non spécifié
 * @param roomData - Données de la salle à créer
 * @returns La salle créée
 */
export async function createRoom(roomData: Omit<Room, 'id' | 'created_at' | 'updated_at'>): Promise<Room> {
  const client = await getClient();
  try {
    // Prix par défaut si non spécifié (30€ par personne)
    const defaultPrice = 30.00;
    const price = roomData.price !== undefined && roomData.price > 0 ? roomData.price : defaultPrice;
    
    const result = await client.query(
      `INSERT INTO rooms (name, description, price, duration, max_people, objects_to_destroy, included, image_url, is_active)
       VALUES ($1, $2, $3, $4, $5, $6::text[], $7::text[], $8, $9)
       RETURNING *`,
      [
        roomData.name,
        roomData.description,
        price,
        roomData.duration,
        roomData.max_people,
        (roomData.objects_to_destroy ?? []) as unknown as string[],
        (roomData.included ?? []) as unknown as string[],
        roomData.image_url || null,
        roomData.is_active
      ]
    );
    const row = result.rows[0];
    return {
      ...row,
      objects_to_destroy: row.objects_to_destroy || [],
      included: row.included || []
    };
  } finally {
    client.release();
  }
}

/**
 * Met à jour le prix de toutes les salles qui n'ont pas de prix défini
 * @param defaultPrice - Prix par défaut à appliquer (30€ par défaut)
 * @returns Nombre de salles mises à jour
 */
export async function ensureAllRoomsHavePrice(defaultPrice: number = 30.00): Promise<number> {
  const client = await getClient();
  try {
    const result = await client.query(
      'UPDATE rooms SET price = $1, updated_at = CURRENT_TIMESTAMP WHERE price IS NULL OR price = 0',
      [defaultPrice]
    );
    return result.rowCount || 0;
  } finally {
    client.release();
  }
}

/**
 * Récupère toutes les salles sans prix défini
 * @returns Liste des salles sans prix
 */
export async function getRoomsWithoutPrice(): Promise<Room[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM rooms WHERE price IS NULL OR price = 0 ORDER BY name'
    );
    return result.rows.map(row => ({
      ...row,
      objects_to_destroy: row.objects_to_destroy || [],
      included: row.included || []
    }));
  } finally {
    client.release();
  }
}

export async function updateRoom(id: string, roomData: Partial<Room>): Promise<Room | null> {
  const client = await getClient();
  try {
    console.log('🔧 updateRoom - ID:', id);
    console.log('🔧 updateRoom - roomData reçu:', roomData);
    
    const fields = [];
    const values = [];
    let paramCount = 1;

    if (roomData.name !== undefined) {
      fields.push(`name = $${paramCount++}`);
      values.push(roomData.name);
    }
    if (roomData.description !== undefined) {
      fields.push(`description = $${paramCount++}`);
      values.push(roomData.description);
    }
    if (roomData.price !== undefined) {
      fields.push(`price = $${paramCount++}`);
      values.push(roomData.price);
    }
    if (roomData.duration !== undefined) {
      fields.push(`duration = $${paramCount++}`);
      values.push(roomData.duration);
    }
    if (roomData.max_people !== undefined) {
      fields.push(`max_people = $${paramCount++}`);
      values.push(roomData.max_people);
    }
    if (roomData.objects_to_destroy !== undefined) {
      fields.push(`objects_to_destroy = $${paramCount++}::text[]`);
      // Si le tableau est vide, on le traite comme un tableau vide en base
      values.push(Array.isArray(roomData.objects_to_destroy) && roomData.objects_to_destroy.length === 0 
        ? [] 
        : (roomData.objects_to_destroy ?? []) as unknown as string[]);
    }
    if (roomData.included !== undefined) {
      fields.push(`included = $${paramCount++}::text[]`);
      // Si le tableau est vide, on le traite comme un tableau vide en base
      values.push(Array.isArray(roomData.included) && roomData.included.length === 0 
        ? [] 
        : (roomData.included ?? []) as unknown as string[]);
    }
    if (roomData.image_url !== undefined) {
      fields.push(`image_url = $${paramCount++}`);
      values.push(roomData.image_url);
    }
    if (roomData.is_active !== undefined) {
      fields.push(`is_active = $${paramCount++}`);
      values.push(roomData.is_active);
    }

    console.log('🔧 updateRoom - fields construits:', fields);
    console.log('🔧 updateRoom - values construites:', values);
    
    if (fields.length === 0) {
      console.log('🔧 updateRoom - AUCUN CHAMP À METTRE À JOUR, return null');
      return null;
    }

    values.push(id);
    const sqlQuery = `UPDATE rooms SET ${fields.join(', ')} WHERE id = $${paramCount} RETURNING *`;
    console.log('🔧 updateRoom - SQL query:', sqlQuery);
    console.log('🔧 updateRoom - Final values:', values);
    
    const result = await client.query(sqlQuery, values);
    
    console.log('🔧 updateRoom - Résultat SQL:', result.rows.length > 0 ? 'ROWS FOUND' : 'NO ROWS');

    if (result.rows.length === 0) return null;
    const row = result.rows[0];
    return {
      ...row,
      objects_to_destroy: row.objects_to_destroy || [],
      included: row.included || []
    };
  } finally {
    client.release();
  }
}

export async function deleteRoom(id: string): Promise<boolean> {
  const client = await getClient();
  try {
    const result = await client.query(
      'DELETE FROM rooms WHERE id = $1',
      [id]
    );
    return (result.rowCount ?? 0) > 0;
  } finally {
    client.release();
  }
}

export async function toggleRoomStatus(id: string): Promise<Room | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'UPDATE rooms SET is_active = NOT is_active WHERE id = $1 RETURNING *',
      [id]
    );
    if (result.rows.length === 0) return null;
    const row = result.rows[0];
    return {
      ...row,
      objects_to_destroy: row.objects_to_destroy || [],
      included: row.included || []
    };
  } finally {
    client.release();
  }
}

// Gestion des réservations
export async function getAllReservations(): Promise<any[]> {
  const client = await getClient();
  try {
    const result = await client.query(`
      SELECT
        id, reservation_number, customer_name, customer_email, customer_phone,
        room_name, date, time_slot, duration, participants, status, amount,
        special_requests, created_at, updated_at,
        payment_id, payment_status, payment_amount, payment_date,
        refund_amount, refund_date, payment_error,
        first_name, last_name, email, phone, number_of_people, notes, time
      FROM reservations
      ORDER BY created_at DESC
    `);
    return result.rows;
  } finally {
    client.release();
  }
}

export async function getReservationById(id: string): Promise<Reservation | null> {
  const client = await getClient();
  try {
    const result = await client.query(`
      SELECT
        id, reservation_number, customer_name, customer_email, customer_phone,
        room_name, date, time_slot, duration, participants, status, amount,
        special_requests, created_at, updated_at,
        payment_id, payment_status, payment_amount, payment_date,
        refund_amount, refund_date, payment_error,
        first_name, last_name, email, phone, number_of_people, notes, time
      FROM reservations WHERE id = $1`,
      [id]
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

/**
 * Met à jour manuellement le statut de paiement d'une réservation
 */
export async function updateReservationPaymentStatus(
  id: string,
  paymentId: string,
  paymentStatus: string,
  paymentAmount?: number,
  paymentDate?: Date,
  paymentError?: string
): Promise<any> {
  const client = await getClient();
  try {
    const result = await client.query(`
      UPDATE reservations
      SET
        payment_id = $2,
        payment_status = $3,
        payment_amount = $4,
        payment_date = $5,
        payment_error = $6,
        updated_at = NOW()
      WHERE id = $1
      RETURNING *`,
      [id, paymentId, paymentStatus, paymentAmount, paymentDate, paymentError]
    );
    return result.rows[0];
  } finally {
    client.release();
  }
}

export async function createReservation(reservationData: any): Promise<any> {
  const client = await getClient();
  try {
    // DEBUG: Log des données reçues
    console.log('🔧 createReservation - Données reçues:', reservationData);
    
    // Générer un numéro de réservation si pas fourni
    const reservationNumber = reservationData.reservation_number || await generateReservationNumber();
    
    // DEBUG: Log des valeurs finales
    console.log('🔧 createReservation - Valeurs finales:', {
      reservationNumber,
      first_name: reservationData.first_name,
      last_name: reservationData.last_name,
      email: reservationData.email,
      phone: reservationData.phone,
      room_name: reservationData.room_name,
      date: reservationData.date,
      time: reservationData.time,
      duration: reservationData.duration,
      number_of_people: reservationData.number_of_people,
      status: reservationData.status,
      amount: reservationData.amount,
      notes: reservationData.notes
    });
    
    const result = await client.query(
      `INSERT INTO reservations (reservation_number, first_name, last_name, email, phone, address, room_name, date, time, duration, number_of_people, status, amount, notes)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
       RETURNING *`,
      [
        reservationNumber,
        reservationData.first_name,
        reservationData.last_name,
        reservationData.email,
        reservationData.phone,
        reservationData.address || null,
        reservationData.room_name,
        reservationData.date,
        reservationData.time,
        reservationData.duration,
        reservationData.number_of_people,
        reservationData.status,
        reservationData.amount,
        reservationData.notes
      ]
    );
    return result.rows[0];
  } finally {
    client.release();
  }
}

export async function updateReservation(id: string, reservationData: Partial<Reservation>): Promise<Reservation | null> {
  const client = await getClient();
  try {
    const fields: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    Object.entries(reservationData).forEach(([key, value]) => {
      if (value !== undefined && key !== 'id' && key !== 'created_at' && key !== 'updated_at') {
        fields.push(`${key} = $${paramCount++}`);
        values.push(value);
      }
    });

    if (fields.length === 0) return null;

    values.push(id);
    const result = await client.query(
      `UPDATE reservations SET ${fields.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      values
    );

    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

/**
 * Met à jour une réservation par son numéro de réservation
 * Utilisé par les webhooks Payplug
 */
export async function updateReservationByNumber(reservationNumber: string, reservationData: Partial<Reservation>): Promise<Reservation | null> {
  const client = await getClient();
  try {
    const fields: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    Object.entries(reservationData).forEach(([key, value]) => {
      if (value !== undefined && key !== 'id' && key !== 'created_at' && key !== 'updated_at') {
        fields.push(`${key} = $${paramCount++}`);
        values.push(value);
      }
    });

    if (fields.length === 0) return null;

    values.push(reservationNumber);
    const result = await client.query(
      `UPDATE reservations SET ${fields.join(', ')} WHERE reservation_number = $${paramCount} RETURNING *`,
      values
    );

    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

export async function deleteReservation(id: string): Promise<boolean> {
  const client = await getClient();
  try {
    const result = await client.query(
      'DELETE FROM reservations WHERE id = $1',
      [id]
    );
    return (result.rowCount ?? 0) > 0;
  } finally {
    client.release();
  }
}

// Gestion SMTP
export async function getSmtpConfig(): Promise<SmtpConfig | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM smtp_config WHERE is_active = true ORDER BY created_at DESC LIMIT 1'
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

// Fonction simple de chiffrement/déchiffrement pour les mots de passe SMTP
function encryptPassword(password: string): string {
  // Chiffrement simple avec Base64 (pour la démo - en production, utiliser crypto)
  return Buffer.from(password).toString('base64');
}

function decryptPassword(encryptedPassword: string): string {
  // Déchiffrement simple avec Base64 (pour la démo - en production, utiliser crypto)
  return Buffer.from(encryptedPassword, 'base64').toString('utf-8');
}

export async function saveSmtpConfig(configData: Omit<SmtpConfig, 'id' | 'created_at' | 'updated_at'>): Promise<SmtpConfig> {
  const client = await getClient();
  try {
    // Désactiver toutes les configurations existantes
    await client.query('UPDATE smtp_config SET is_active = false');
    
    // Chiffrer le mot de passe avant de le stocker
    const encryptedPassword = encryptPassword(configData.password_encrypted);
    
    // Insérer la nouvelle configuration
    const result = await client.query(
      `INSERT INTO smtp_config (host, port, secure, username, password_encrypted, from_email, tls_reject_unauthorized, tls_min_version, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [
        configData.host,
        configData.port,
        configData.secure,
        configData.username,
        encryptedPassword,
        configData.from_email,
        configData.tls_reject_unauthorized,
        configData.tls_min_version,
        configData.is_active
      ]
    );
    return result.rows[0];
  } finally {
    client.release();
  }
}

// Nouvelle fonction pour récupérer la configuration SMTP avec mot de passe déchiffré
export async function getSmtpConfigDecrypted(): Promise<(SmtpConfig & { password: string }) | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM smtp_config WHERE is_active = true ORDER BY created_at DESC LIMIT 1'
    );
    
    if (!result.rows[0]) {
      return null;
    }
    
    const config = result.rows[0];
    return {
      ...config,
      password: decryptPassword(config.password_encrypted)
    };
  } finally {
    client.release();
  }
}

// Gestion des notifications
export async function createNotification(notificationData: Omit<Notification, 'id' | 'created_at'>): Promise<Notification> {
  const client = await getClient();
  try {
    const result = await client.query(
      `INSERT INTO notifications (type, recipient_email, recipient_name, subject, message, status)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [
        notificationData.type,
        notificationData.recipient_email,
        notificationData.recipient_name,
        notificationData.subject,
        notificationData.message,
        notificationData.status
      ]
    );
    return result.rows[0];
  } finally {
    client.release();
  }
}

export async function updateNotificationStatus(id: string, status: string, sentAt?: Date, errorMessage?: string): Promise<Notification | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      `UPDATE notifications SET status = $1, sent_at = $2, error_message = $3 WHERE id = $4 RETURNING *`,
      [status, sentAt, errorMessage, id]
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

export async function getPendingNotifications(): Promise<Notification[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM notifications WHERE status = \'pending\' ORDER BY created_at ASC'
    );
    return result.rows;
  } finally {
    client.release();
  }
}

// Gestion des pages
export async function getAllPages(): Promise<Page[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM pages ORDER BY created_at DESC'
    );
    return result.rows.map(row => ({
      ...row,
      keywords: row.keywords || []
    }));
  } finally {
    client.release();
  }
}

export async function getPageById(id: string): Promise<Page | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM pages WHERE id = $1',
      [id]
    );
    if (result.rows.length === 0) return null;
    const row = result.rows[0];
    return {
      ...row,
      keywords: row.keywords || []
    };
  } finally {
    client.release();
  }
}

export async function getPageBySlug(slug: string): Promise<Page | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM pages WHERE slug = $1 AND is_published = true',
      [slug]
    );
    if (result.rows.length === 0) return null;
    const row = result.rows[0];
    return {
      ...row,
      keywords: row.keywords || []
    };
  } finally {
    client.release();
  }
}

export async function createPage(pageData: Omit<Page, 'id' | 'created_at' | 'updated_at'>): Promise<Page> {
  const client = await getClient();
  try {
    const result = await client.query(
      `INSERT INTO pages (title, slug, content, meta_description, seo_title, keywords, is_published)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [
        pageData.title,
        pageData.slug,
        pageData.content,
        pageData.meta_description,
        pageData.seo_title,
        pageData.keywords,
        pageData.is_published
      ]
    );
    const row = result.rows[0];
    return {
      ...row,
      keywords: row.keywords || []
    };
  } finally {
    client.release();
  }
}

export async function updatePage(id: string, pageData: Partial<Page>): Promise<Page | null> {
  const client = await getClient();
  try {
    const fields: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    Object.entries(pageData).forEach(([key, value]) => {
      if (value !== undefined && key !== 'id' && key !== 'created_at' && key !== 'updated_at') {
        fields.push(`${key} = $${paramCount++}`);
        values.push(value);
      }
    });

    if (fields.length === 0) return null;

    values.push(id);
    const result = await client.query(
      `UPDATE pages SET ${fields.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      values
    );

    if (result.rows.length === 0) return null;
    const row = result.rows[0];
    return {
      ...row,
      keywords: row.keywords || []
    };
  } finally {
    client.release();
  }
}

export async function deletePage(id: string): Promise<boolean> {
  const client = await getClient();
  try {
    const result = await client.query(
      'DELETE FROM pages WHERE id = $1',
      [id]
    );
    return (result.rowCount ?? 0) > 0;
  } finally {
    client.release();
  }
}



// Fermeture de la pool
export async function closePool() {
  await pool.end();
}

// Test de connexion
export async function testConnection(): Promise<boolean> {
  try {
    const client = await getClient();
    await client.query('SELECT 1');
    client.release();
    return true;
  } catch (error) {
    console.error('Erreur de connexion à la base de données:', error);
    return false;
  }
}

// Fonctions utilitaires manquantes
/**
 * Génère un numéro de réservation unique basé sur la date du jour
 * Format: YYMMDD + numéro séquentiel sur 3 chiffres (ex: 250904001)
 * @returns Promise<string> - Numéro de réservation unique
 */
export async function generateReservationNumber(): Promise<string> {
  const client = await getClient();
  try {
    // Compter les réservations du jour actuel
    const result = await client.query(
      'SELECT COUNT(*) as count FROM reservations WHERE DATE(created_at) = CURRENT_DATE'
    );
    const count = parseInt(result.rows[0].count) + 1;
    
    // Format: YYMMDD (ex: 250904 pour le 4 septembre 2025)
    const now = new Date();
    const year = String(now.getFullYear()).slice(-2); // 25 (2 derniers chiffres de 2025)
    const month = String(now.getMonth() + 1).padStart(2, '0'); // 09
    const day = String(now.getDate()).padStart(2, '0'); // 04
    const dateString = `${year}${month}${day}`; // 250904
    
    // Numéro séquentiel sur 3 chiffres (ex: 001, 002, 150)
    const sequenceNumber = count.toString().padStart(3, '0');
    
    return `${dateString}${sequenceNumber}`;
  } finally {
    client.release();
  }
}

export async function getReservationByNumber(reservationNumber: string): Promise<Reservation | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM reservations WHERE reservation_number = $1',
      [reservationNumber]
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

export async function getReservationsByDate(date: string): Promise<Reservation[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM reservations WHERE date = $1 ORDER BY time',
      [date]
    );
    return result.rows;
  } finally {
    client.release();
  }
}

export async function updateReservationStatus(id: string, status: string): Promise<Reservation | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'UPDATE reservations SET status = $1 WHERE id = $2 RETURNING *',
      [status, id]
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

export async function getActiveRooms(): Promise<Room[]> {
  return getAllRooms(); // Cette fonction retourne déjà les salles actives
}

export async function getUpcomingReservations(hours: number = 24): Promise<Reservation[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      `SELECT * FROM reservations 
       WHERE date >= CURRENT_DATE 
       AND date <= CURRENT_DATE + INTERVAL '${hours} hours'
       AND status = 'confirmed'
       ORDER BY date, time`,
    );
    return result.rows;
  } finally {
    client.release();
  }
}

export async function getSmtpConfigForDisplay(): Promise<any> {
  const config = await getSmtpConfig();
  if (!config) return null;
  
  return {
    ...config,
    password_encrypted: config.password_encrypted ? '***' : null
  };
}

// ============================================================================
// FONCTIONS POUR LES SECTIONS DE LA PAGE D'ACCUEIL
// ============================================================================

/**
 * Récupère toutes les sections de la page d'accueil
 */
export async function getAllHomepageSections(): Promise<HomepageSection[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM homepage_sections ORDER BY order_index ASC'
    );
    return result.rows;
  } finally {
    client.release();
  }
}

/**
 * Récupère une section par sa clé
 */
export async function getHomepageSectionByKey(sectionKey: string): Promise<HomepageSection | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM homepage_sections WHERE section_key = $1',
      [sectionKey]
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

/**
 * Récupère une section par son ID
 */
export async function getHomepageSectionById(id: string): Promise<HomepageSection | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM homepage_sections WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

/**
 * Crée une nouvelle section
 */
export async function createHomepageSection(sectionData: Omit<HomepageSection, 'id' | 'created_at' | 'updated_at'>): Promise<HomepageSection> {
  const client = await getClient();
  try {
    const result = await client.query(
      `INSERT INTO homepage_sections (
        section_key, title, subtitle, content, image_url, video_url, 
        background_color, text_color, order_index, is_active
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) 
      RETURNING *`,
      [
        sectionData.section_key,
        sectionData.title,
        sectionData.subtitle,
        sectionData.content,
        sectionData.image_url,
        sectionData.video_url,
        sectionData.background_color,
        sectionData.text_color,
        sectionData.order_index,
        sectionData.is_active
      ]
    );
    return result.rows[0];
  } finally {
    client.release();
  }
}

/**
 * Met à jour une section existante
 */
export async function updateHomepageSection(id: string, sectionData: Partial<Omit<HomepageSection, 'id' | 'created_at' | 'updated_at'>>): Promise<HomepageSection | null> {
  const client = await getClient();
  try {
    const fields: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    // Construction dynamique de la requête
    Object.entries(sectionData).forEach(([key, value]) => {
      if (value !== undefined) {
        fields.push(`${key} = $${paramIndex}`);
        values.push(value);
        paramIndex++;
      }
    });

    if (fields.length === 0) {
      throw new Error('Aucun champ à mettre à jour');
    }

    values.push(id);
    const result = await client.query(
      `UPDATE homepage_sections SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP WHERE id = $${paramIndex} RETURNING *`,
      values
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

/**
 * Supprime une section
 */
export async function deleteHomepageSection(id: string): Promise<boolean> {
  const client = await getClient();
  try {
    const result = await client.query(
      'DELETE FROM homepage_sections WHERE id = $1',
      [id]
    );
    return (result.rowCount ?? 0) > 0;
  } finally {
    client.release();
  }
}

/**
 * Récupère les sections actives pour l'affichage public
 */
export async function getActiveHomepageSections(): Promise<HomepageSection[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM homepage_sections WHERE is_active = true ORDER BY order_index ASC'
    );
    return result.rows;
  } finally {
    client.release();
  }
}

/**
 * Met à jour l'ordre de toutes les sections en une seule transaction
 */
export async function reorderHomepageSections(sections: Array<{id: string, order_index: number}>): Promise<HomepageSection[]> {
  const client = await getClient();
  try {
    await client.query('BEGIN');
    
    // Mettre à jour l'ordre de chaque section
    for (const section of sections) {
      await client.query(
        'UPDATE homepage_sections SET order_index = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
        [section.order_index, section.id]
      );
    }
    
    await client.query('COMMIT');
    
    // Récupérer toutes les sections mises à jour
    const result = await client.query(
      'SELECT * FROM homepage_sections ORDER BY order_index ASC'
    );
    
    return result.rows;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// ===== FONCTIONS POUR LES SECTIONS GLOBALES =====

/**
 * Récupère toutes les sections globales
 */
export async function getAllGlobalSections(): Promise<GlobalSection[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM global_sections ORDER BY page_identifier, order_index ASC'
    );
    return result.rows;
  } finally {
    client.release();
  }
}

/**
 * Récupère les sections globales par page
 */
export async function getGlobalSectionsByPage(pageIdentifier: string): Promise<GlobalSection[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM global_sections WHERE page_identifier = $1 AND is_active = true ORDER BY order_index ASC',
      [pageIdentifier]
    );
    return result.rows;
  } finally {
    client.release();
  }
}

/**
 * Récupère une section globale par sa clé
 */
export async function getGlobalSectionByKey(sectionKey: string): Promise<GlobalSection | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM global_sections WHERE section_key = $1',
      [sectionKey]
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

/**
 * Récupère une section globale par son ID
 */
export async function getGlobalSectionById(id: string): Promise<GlobalSection | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM global_sections WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

/**
 * Crée une nouvelle section globale
 */
export async function createGlobalSection(sectionData: Omit<GlobalSection, 'id' | 'created_at' | 'updated_at'>): Promise<GlobalSection> {
  const client = await getClient();
  try {
    const result = await client.query(
      `INSERT INTO global_sections (
        section_key, section_name, title, subtitle, content, image_url, video_url, 
        background_color, text_color, order_index, is_active, page_identifier
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) 
      RETURNING *`,
      [
        sectionData.section_key,
        sectionData.section_name,
        sectionData.title,
        sectionData.subtitle,
        sectionData.content,
        sectionData.image_url,
        sectionData.video_url,
        sectionData.background_color,
        sectionData.text_color,
        sectionData.order_index,
        sectionData.is_active,
        sectionData.page_identifier
      ]
    );
    return result.rows[0];
  } finally {
    client.release();
  }
}

/**
 * Met à jour une section globale existante
 */
export async function updateGlobalSection(id: string, sectionData: Partial<Omit<GlobalSection, 'id' | 'created_at' | 'updated_at'>>): Promise<GlobalSection | null> {
  const client = await getClient();
  try {
    const fields: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    // Construction dynamique de la requête
    Object.entries(sectionData).forEach(([key, value]) => {
      if (value !== undefined) {
        fields.push(`${key} = $${paramIndex}`);
        values.push(value);
        paramIndex++;
      }
    });

    if (fields.length === 0) {
      throw new Error('Aucun champ à mettre à jour');
    }

    values.push(id);
    const result = await client.query(
      `UPDATE global_sections SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP WHERE id = $${paramIndex} RETURNING *`,
      values
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

/**
 * Supprime une section globale
 */
export async function deleteGlobalSection(id: string): Promise<boolean> {
  const client = await getClient();
  try {
    const result = await client.query(
      'DELETE FROM global_sections WHERE id = $1',
      [id]
    );
    return (result.rowCount ?? 0) > 0;
  } finally {
    client.release();
  }
}

/**
 * Bascule le statut actif/inactif d'une section globale
 */
export async function toggleGlobalSectionStatus(id: string): Promise<GlobalSection | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'UPDATE global_sections SET is_active = NOT is_active, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

// ==================== FONCTIONS DE STATISTIQUES ====================

/**
 * Interface pour les statistiques du dashboard
 */
export interface DashboardStats {
  totalReservations: number;
  todayReservations: number;
  totalRevenue: number;
  activeRooms: number;
  pendingReservations: number;
  confirmedReservations: number;
  cancelledReservations: number;
}

/**
 * Récupère les statistiques complètes du dashboard
 */
export async function getDashboardStats(): Promise<DashboardStats> {
  const client = await getClient();
  try {
    // Statistiques des réservations
    const reservationsResult = await client.query(`
      SELECT 
        COUNT(*) as total,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending,
        COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as confirmed,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled,
        COALESCE(SUM(CASE WHEN status = 'confirmed' THEN amount ELSE 0 END), 0) as total_revenue,
        COUNT(CASE WHEN DATE(created_at) = CURRENT_DATE THEN 1 END) as today
      FROM reservations
    `);

    // Nombre de salles actives
    const roomsResult = await client.query(`
      SELECT COUNT(*) as active_rooms
      FROM rooms 
      WHERE is_active = true
    `);

    const stats = reservationsResult.rows[0];
    const rooms = roomsResult.rows[0];

    return {
      totalReservations: parseInt(stats.total) || 0,
      todayReservations: parseInt(stats.today) || 0,
      totalRevenue: parseFloat(stats.total_revenue) || 0,
      activeRooms: parseInt(rooms.active_rooms) || 0,
      pendingReservations: parseInt(stats.pending) || 0,
      confirmedReservations: parseInt(stats.confirmed) || 0,
      cancelledReservations: parseInt(stats.cancelled) || 0
    };
  } finally {
    client.release();
  }
}

/**
 * Récupère les réservations récentes pour le dashboard
 */
export async function getRecentReservations(limit: number = 5): Promise<Reservation[]> {
  const client = await getClient();
  try {
    const result = await client.query(`
      SELECT * FROM reservations 
      ORDER BY created_at DESC 
      LIMIT $1
    `, [limit]);
    return result.rows;
  } finally {
    client.release();
  }
}

/**
 * Récupère les statistiques des réservations par statut
 */
export async function getReservationStatsByStatus(): Promise<{
  pending: number;
  confirmed: number;
  cancelled: number;
}> {
  const client = await getClient();
  try {
    const result = await client.query(`
      SELECT 
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending,
        COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as confirmed,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled
      FROM reservations
    `);

    const stats = result.rows[0];
    return {
      pending: parseInt(stats.pending) || 0,
      confirmed: parseInt(stats.confirmed) || 0,
      cancelled: parseInt(stats.cancelled) || 0
    };
  } finally {
    client.release();
  }
}

/**
 * Récupère les revenus par période
 */
export async function getRevenueByPeriod(period: 'today' | 'week' | 'month' | 'year'): Promise<number> {
  const client = await getClient();
  try {
    let dateFilter = '';
    switch (period) {
      case 'today':
        dateFilter = 'DATE(created_at) = CURRENT_DATE';
        break;
      case 'week':
        dateFilter = 'created_at >= CURRENT_DATE - INTERVAL \'7 days\'';
        break;
      case 'month':
        dateFilter = 'created_at >= CURRENT_DATE - INTERVAL \'30 days\'';
        break;
      case 'year':
        dateFilter = 'created_at >= CURRENT_DATE - INTERVAL \'365 days\'';
        break;
    }

    const result = await client.query(`
      SELECT COALESCE(SUM(amount), 0) as revenue
      FROM reservations 
      WHERE status = 'confirmed' AND ${dateFilter}
    `);

    return parseFloat(result.rows[0].revenue) || 0;
  } finally {
    client.release();
  }
}

// ===== GESTION DES UTILISATEURS ADMINISTRATEURS =====

export interface AdminUser {
  id: string;
  username: string;
  password_hash: string;
  role: 'admin' | 'super-admin';
  created_at: Date;
  updated_at: Date;
  last_login?: Date;
}

/**
 * Crée la table des utilisateurs administrateurs si elle n'existe pas
 */
export async function createAdminUsersTable(): Promise<void> {
  const client = await pool.connect();
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS admin_users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        username VARCHAR(50) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'super-admin')),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        last_login TIMESTAMP WITH TIME ZONE
      )
    `);

    // Créer un index sur le nom d'utilisateur
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_admin_users_username ON admin_users(username)
    `);

    // Insérer les utilisateurs par défaut s'ils n'existent pas
    await insertDefaultAdminUsers(client);
  } finally {
    client.release();
  }
}

/**
 * Insère les utilisateurs administrateurs par défaut
 */
async function insertDefaultAdminUsers(client: PoolClient): Promise<void> {
  try {
    // Vérifier si des utilisateurs existent déjà
    const result = await client.query('SELECT COUNT(*) FROM admin_users');
    const userCount = parseInt(result.rows[0].count);

    if (userCount === 0) {
      // Hasher les mots de passe (en production, utiliser bcrypt)
      const adminPasswordHash = 'admin123'; // À remplacer par un vrai hash
      const superAdminPasswordHash = '@dm1n1str@t3uR!'; // À remplacer par un vrai hash

      await client.query(`
        INSERT INTO admin_users (username, password_hash, role) VALUES
        ('admin', $1, 'admin'),
        ('administrateur', $2, 'super-admin')
      `, [adminPasswordHash, superAdminPasswordHash]);

      console.log('Utilisateurs administrateurs par défaut créés');
    }
  } catch (error) {
    console.error('Erreur lors de la création des utilisateurs par défaut:', error);
  }
}

/**
 * Récupère tous les utilisateurs administrateurs
 */
export async function getAdminUsers(): Promise<AdminUser[]> {
  const client = await pool.connect();
  try {
    const result = await client.query(`
      SELECT id, username, role, created_at, updated_at, last_login
      FROM admin_users
      ORDER BY created_at DESC
    `);

    return result.rows.map(row => ({
      id: row.id,
      username: row.username,
      password_hash: '', // Ne pas exposer le hash
      role: row.role,
      created_at: row.created_at,
      updated_at: row.updated_at,
      last_login: row.last_login
    }));
  } finally {
    client.release();
  }
}

/**
 * Récupère un utilisateur administrateur par son ID
 */
export async function getAdminUserById(id: string): Promise<AdminUser | null> {
  const client = await pool.connect();
  try {
    const result = await client.query(`
      SELECT id, username, password_hash, role, created_at, updated_at, last_login
      FROM admin_users
      WHERE id = $1
    `, [id]);

    if (result.rows.length === 0) {
      return null;
    }

    const row = result.rows[0];
    return {
      id: row.id,
      username: row.username,
      password_hash: row.password_hash,
      role: row.role,
      created_at: row.created_at,
      updated_at: row.updated_at,
      last_login: row.last_login
    };
  } finally {
    client.release();
  }
}

/**
 * Récupère un utilisateur administrateur par son nom d'utilisateur
 */
export async function getAdminUserByUsername(username: string): Promise<AdminUser | null> {
  const client = await pool.connect();
  try {
    const result = await client.query(`
      SELECT id, username, password_hash, role, created_at, updated_at, last_login
      FROM admin_users
      WHERE username = $1
    `, [username]);

    if (result.rows.length === 0) {
      return null;
    }

    const row = result.rows[0];
    return {
      id: row.id,
      username: row.username,
      password_hash: row.password_hash,
      role: row.role,
      created_at: row.created_at,
      updated_at: row.updated_at,
      last_login: row.last_login
    };
  } finally {
    client.release();
  }
}

/**
 * Crée un nouvel utilisateur administrateur
 */
export async function createAdminUser(userData: {
  username: string;
  password: string;
  role: 'admin' | 'super-admin';
}): Promise<AdminUser> {
  const client = await pool.connect();
  try {
    // En production, hasher le mot de passe avec bcrypt
    const passwordHash = userData.password; // À remplacer par bcrypt.hash()

    const result = await client.query(`
      INSERT INTO admin_users (username, password_hash, role)
      VALUES ($1, $2, $3)
      RETURNING id, username, role, created_at, updated_at, last_login
    `, [userData.username, passwordHash, userData.role]);

    const row = result.rows[0];
    return {
      id: row.id,
      username: row.username,
      password_hash: '', // Ne pas exposer le hash
      role: row.role,
      created_at: row.created_at,
      updated_at: row.updated_at,
      last_login: row.last_login
    };
  } finally {
    client.release();
  }
}

/**
 * Met à jour un utilisateur administrateur
 */
export async function updateAdminUser(id: string, updateData: {
  username?: string;
  password?: string;
  role?: 'admin' | 'super-admin';
}): Promise<AdminUser> {
  const client = await pool.connect();
  try {
    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    // Construire les champs à mettre à jour
    if (updateData.username !== undefined) {
      updates.push(`username = $${paramCount}`);
      values.push(updateData.username);
      paramCount++;
    }

    if (updateData.password !== undefined && updateData.password.trim() !== '') {
      // En production, hasher le mot de passe avec bcrypt
      const passwordHash = updateData.password; // À remplacer par bcrypt.hash()
      updates.push(`password_hash = $${paramCount}`);
      values.push(passwordHash);
      paramCount++;
    }

    if (updateData.role !== undefined) {
      updates.push(`role = $${paramCount}`);
      values.push(updateData.role);
      paramCount++;
    }

    // Toujours mettre à jour updated_at
    updates.push(`updated_at = CURRENT_TIMESTAMP`);
    
    // Ajouter l'ID à la fin
    values.push(id);

    const query = `
      UPDATE admin_users
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING id, username, role, created_at, updated_at, last_login
    `;
    

    const result = await client.query(query, values);

    if (result.rows.length === 0) {
      throw new Error('Utilisateur non trouvé');
    }

    const row = result.rows[0];
    return {
      id: row.id,
      username: row.username,
      password_hash: '', // Ne pas exposer le hash
      role: row.role,
      created_at: row.created_at,
      updated_at: row.updated_at,
      last_login: row.last_login
    };
  } finally {
    client.release();
  }
}

/**
 * Supprime un utilisateur administrateur
 */
export async function deleteAdminUser(id: string): Promise<void> {
  const client = await pool.connect();
  try {
    const result = await client.query(`
      DELETE FROM admin_users
      WHERE id = $1
    `, [id]);

    if (result.rowCount === 0) {
      throw new Error('Utilisateur non trouvé');
    }
  } finally {
    client.release();
  }
}

/**
 * Met à jour la dernière connexion d'un utilisateur
 */
export async function updateLastLogin(username: string): Promise<void> {
  const client = await pool.connect();
  try {
    await client.query(`
      UPDATE admin_users
      SET last_login = CURRENT_TIMESTAMP
      WHERE username = $1
    `, [username]);
  } finally {
    client.release();
  }
}

// ==================== FONCTIONS DE GESTION DU PIED DE PAGE ====================

/**
 * Récupère la configuration du pied de page
 */
export async function getFooterConfig(): Promise<FooterConfig | null> {
  const client = await pool.connect();
  try {
    const result = await client.query(`
      SELECT * FROM footer_config
      ORDER BY created_at DESC
      LIMIT 1
    `);

    if (result.rows.length === 0) {
      return null;
    }

    const row = result.rows[0];
    return {
      id: row.id,
      site_name: row.site_name,
      site_description: row.site_description,
      site_slogan: row.site_slogan,
      contact_phone: row.contact_phone,
      contact_email: row.contact_email,
      contact_address: row.contact_address,
      opening_hours_monday: row.opening_hours_monday,
      opening_hours_tuesday: row.opening_hours_tuesday,
      opening_hours_wednesday: row.opening_hours_wednesday,
      opening_hours_thursday: row.opening_hours_thursday,
      opening_hours_friday: row.opening_hours_friday,
      opening_hours_saturday: row.opening_hours_saturday,
      opening_hours_sunday: row.opening_hours_sunday,
      cta_title: row.cta_title,
      cta_subtitle: row.cta_subtitle,
      cta_button_text: row.cta_button_text,
      cta_button_url: row.cta_button_url,
      legal_links: row.legal_links || [],
      copyright_text: row.copyright_text,
      created_at: row.created_at,
      updated_at: row.updated_at
    };
  } finally {
    client.release();
  }
}

/**
 * Met à jour la configuration du pied de page
 */
export async function updateFooterConfig(configData: Partial<FooterConfig>): Promise<FooterConfig> {
  const client = await pool.connect();
  try {
    // Vérifier s'il existe déjà une configuration
    const existingConfig = await getFooterConfig();
    
    if (existingConfig) {
      // Mettre à jour la configuration existante
      const updates: string[] = [];
      const values: any[] = [];
      let paramCount = 1;

      // Construire dynamiquement la requête UPDATE
      const fields = [
        'site_name', 'site_description', 'site_slogan',
        'contact_phone', 'contact_email', 'contact_address',
        'opening_hours_monday', 'opening_hours_tuesday', 'opening_hours_wednesday',
        'opening_hours_thursday', 'opening_hours_friday', 'opening_hours_saturday', 'opening_hours_sunday',
        'cta_title', 'cta_subtitle', 'cta_button_text', 'cta_button_url',
        'legal_links', 'copyright_text'
      ];

      for (const field of fields) {
        if (configData[field as keyof FooterConfig] !== undefined) {
          updates.push(`${field} = $${paramCount}`);
          
          // Gestion spéciale pour les données JSON
          if (field === 'legal_links') {
            // S'assurer que legal_links est un tableau valide
            const legalLinks = configData.legal_links;
            if (Array.isArray(legalLinks)) {
              values.push(JSON.stringify(legalLinks));
            } else {
              values.push('[]');
            }
          } else {
            values.push(configData[field as keyof FooterConfig]);
          }
          paramCount++;
        }
      }

      // Toujours mettre à jour updated_at
      updates.push('updated_at = CURRENT_TIMESTAMP');
      
      // Ajouter l'ID à la fin
      values.push(existingConfig.id);

      const query = `
        UPDATE footer_config
        SET ${updates.join(', ')}
        WHERE id = $${paramCount}
        RETURNING *
      `;

      const result = await client.query(query, values);
      const row = result.rows[0];

      return {
        id: row.id,
        site_name: row.site_name,
        site_description: row.site_description,
        site_slogan: row.site_slogan,
        contact_phone: row.contact_phone,
        contact_email: row.contact_email,
        contact_address: row.contact_address,
        opening_hours_monday: row.opening_hours_monday,
        opening_hours_tuesday: row.opening_hours_tuesday,
        opening_hours_wednesday: row.opening_hours_wednesday,
        opening_hours_thursday: row.opening_hours_thursday,
        opening_hours_friday: row.opening_hours_friday,
        opening_hours_saturday: row.opening_hours_saturday,
        opening_hours_sunday: row.opening_hours_sunday,
        cta_title: row.cta_title,
        cta_subtitle: row.cta_subtitle,
        cta_button_text: row.cta_button_text,
        cta_button_url: row.cta_button_url,
        legal_links: row.legal_links || [],
        copyright_text: row.copyright_text,
        created_at: row.created_at,
        updated_at: row.updated_at
      };
    } else {
      // Créer une nouvelle configuration
      const result = await client.query(`
        INSERT INTO footer_config (
          site_name, site_description, site_slogan,
          contact_phone, contact_email, contact_address,
          opening_hours_monday, opening_hours_tuesday, opening_hours_wednesday,
          opening_hours_thursday, opening_hours_friday, opening_hours_saturday, opening_hours_sunday,
          cta_title, cta_subtitle, cta_button_text, cta_button_url,
          legal_links, copyright_text
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19
        )
        RETURNING *
      `, [
        configData.site_name || 'U SILENZIU',
        configData.site_description,
        configData.site_slogan,
        configData.contact_phone,
        configData.contact_email,
        configData.contact_address,
        configData.opening_hours_monday,
        configData.opening_hours_tuesday,
        configData.opening_hours_wednesday,
        configData.opening_hours_thursday,
        configData.opening_hours_friday,
        configData.opening_hours_saturday,
        configData.opening_hours_sunday,
        configData.cta_title,
        configData.cta_subtitle,
        configData.cta_button_text,
        configData.cta_button_url,
        JSON.stringify(configData.legal_links || []),
        configData.copyright_text
      ]);

      const row = result.rows[0];
      return {
        id: row.id,
        site_name: row.site_name,
        site_description: row.site_description,
        site_slogan: row.site_slogan,
        contact_phone: row.contact_phone,
        contact_email: row.contact_email,
        contact_address: row.contact_address,
        opening_hours_monday: row.opening_hours_monday,
        opening_hours_tuesday: row.opening_hours_tuesday,
        opening_hours_wednesday: row.opening_hours_wednesday,
        opening_hours_thursday: row.opening_hours_thursday,
        opening_hours_friday: row.opening_hours_friday,
        opening_hours_saturday: row.opening_hours_saturday,
        opening_hours_sunday: row.opening_hours_sunday,
        cta_title: row.cta_title,
        cta_subtitle: row.cta_subtitle,
        cta_button_text: row.cta_button_text,
        cta_button_url: row.cta_button_url,
        legal_links: row.legal_links || [],
        copyright_text: row.copyright_text,
        created_at: row.created_at,
        updated_at: row.updated_at
      };
    }
  } finally {
    client.release();
  }
}

// ===== FONCTIONS DE GESTION DE LA CONFIGURATION DE L'EN-TÊTE =====

/**
 * Récupère la configuration de l'en-tête
 */
export async function getHeaderConfig(): Promise<HeaderConfig | null> {
  const client = await pool.connect();
  try {
    const result = await client.query(`
      SELECT * FROM header_config
      ORDER BY created_at DESC
      LIMIT 1
    `);

    if (result.rows.length === 0) {
      return null;
    }

    const row = result.rows[0];
    return {
      id: row.id,
      site_name: row.site_name,
      logo_type: row.logo_type,
      logo_text: row.logo_text,
      logo_image_url: row.logo_image_url,
      logo_alt_text: row.logo_alt_text,
      logo_uploaded_data: row.logo_uploaded_data,
      logo_uploaded_filename: row.logo_uploaded_filename,
      logo_uploaded_mimetype: row.logo_uploaded_mimetype,
      logo_uploaded_size: row.logo_uploaded_size,
      created_at: row.created_at,
      updated_at: row.updated_at
    };
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration de l\'en-tête:', error);
    return null;
  } finally {
    client.release();
  }
}

/**
 * Met à jour la configuration de l'en-tête
 */
export async function updateHeaderConfig(configData: Partial<HeaderConfig>): Promise<HeaderConfig> {
  const client = await pool.connect();
  try {
    // Vérifier s'il existe déjà une configuration
    const existingConfig = await getHeaderConfig();
    
    if (existingConfig) {
      // Mettre à jour la configuration existante
      const updates: string[] = [];
      const values: any[] = [];
      let paramCount = 1;

      // Construire dynamiquement la requête UPDATE
      const fields = [
        'site_name', 'logo_type', 'logo_text', 'logo_image_url', 'logo_alt_text',
        'logo_uploaded_data', 'logo_uploaded_filename', 'logo_uploaded_mimetype', 'logo_uploaded_size'
      ];

      for (const field of fields) {
        if (configData[field as keyof HeaderConfig] !== undefined) {
          updates.push(`${field} = $${paramCount}`);
          values.push(configData[field as keyof HeaderConfig]);
          paramCount++;
        }
      }

      // Toujours mettre à jour updated_at
      updates.push('updated_at = CURRENT_TIMESTAMP');
      
      // Ajouter l'ID à la fin
      values.push(existingConfig.id);

      const query = `
        UPDATE header_config
        SET ${updates.join(', ')}
        WHERE id = $${paramCount}
        RETURNING *
      `;

      const result = await client.query(query, values);
      const row = result.rows[0];

      return {
        id: row.id,
        site_name: row.site_name,
        logo_type: row.logo_type,
        logo_text: row.logo_text,
        logo_image_url: row.logo_image_url,
        logo_alt_text: row.logo_alt_text,
        logo_uploaded_data: row.logo_uploaded_data,
        logo_uploaded_filename: row.logo_uploaded_filename,
        logo_uploaded_mimetype: row.logo_uploaded_mimetype,
        logo_uploaded_size: row.logo_uploaded_size,
        created_at: row.created_at,
        updated_at: row.updated_at
      };
    } else {
      // Créer une nouvelle configuration
      const result = await client.query(`
        INSERT INTO header_config (
          site_name, logo_type, logo_text, logo_image_url, logo_alt_text,
          logo_uploaded_data, logo_uploaded_filename, logo_uploaded_mimetype, logo_uploaded_size
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9
        )
        RETURNING *
      `, [
        configData.site_name || 'U SILENZIU',
        configData.logo_type || 'text',
        configData.logo_text || 'U',
        configData.logo_image_url,
        configData.logo_alt_text || 'Logo U Silenziu',
        configData.logo_uploaded_data,
        configData.logo_uploaded_filename,
        configData.logo_uploaded_mimetype,
        configData.logo_uploaded_size
      ]);

      const row = result.rows[0];
      return {
        id: row.id,
        site_name: row.site_name,
        logo_type: row.logo_type,
        logo_text: row.logo_text,
        logo_image_url: row.logo_image_url,
        logo_alt_text: row.logo_alt_text,
        logo_uploaded_data: row.logo_uploaded_data,
        logo_uploaded_filename: row.logo_uploaded_filename,
        logo_uploaded_mimetype: row.logo_uploaded_mimetype,
        logo_uploaded_size: row.logo_uploaded_size,
        created_at: row.created_at,
        updated_at: row.updated_at
      };
    }
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la configuration de l\'en-tête:', error);
    throw error;
  } finally {
    client.release();
  }
}

// ===== FONCTIONS DE GESTION DE LA CONFIGURATION DE LA PAGE D'ACCUEIL =====

/**
 * Récupère toutes les configurations de la page d'accueil
 * @returns Promise<HomepageConfigItem[]> - Liste des configurations
 */
export async function getAllHomepageConfigs(): Promise<HomepageConfigItem[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM homepage_config WHERE is_active = true ORDER BY config_key'
    );
    return result.rows;
  } finally {
    client.release();
  }
}

/**
 * Récupère la configuration de la page d'accueil sous forme d'objet structuré
 * @returns Promise<HomepageConfig> - Configuration structurée
 */
export async function getHomepageConfig(): Promise<HomepageConfig> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT config_key, config_value, config_type FROM homepage_config WHERE is_active = true'
    );
    
    const config: any = {};
    result.rows.forEach(row => {
      let value: any = row.config_value;
      
      // Conversion selon le type
      if (row.config_type === 'boolean') {
        value = value === 'true';
      } else if (row.config_type === 'number') {
        value = parseFloat(value);
      } else if (row.config_type === 'json') {
        try {
          value = JSON.parse(value);
        } catch (e) {
          value = row.config_value;
        }
      }
      
      config[row.config_key] = value;
    });
    
    return config as HomepageConfig;
  } finally {
    client.release();
  }
}

/**
 * Met à jour une configuration spécifique
 * @param configKey - Clé de la configuration
 * @param configValue - Nouvelle valeur
 * @returns Promise<boolean> - Succès de l'opération
 */
export async function updateHomepageConfig(configKey: string, configValue: string): Promise<boolean> {
  const client = await getClient();
  try {
    const result = await client.query(
      'UPDATE homepage_config SET config_value = $1, updated_at = CURRENT_TIMESTAMP WHERE config_key = $2 AND is_active = true',
      [configValue, configKey]
    );
    return (result.rowCount ?? 0) > 0;
  } finally {
    client.release();
  }
}

/**
 * Met à jour plusieurs configurations en une seule transaction
 * @param configs - Objet contenant les configurations à mettre à jour
 * @returns Promise<boolean> - Succès de l'opération
 */
export async function updateMultipleHomepageConfigs(configs: Partial<HomepageConfig>): Promise<boolean> {
  const client = await getClient();
  try {
    await client.query('BEGIN');
    
    for (const [key, value] of Object.entries(configs)) {
      if (value !== undefined) {
        const stringValue = typeof value === 'boolean' ? value.toString() : String(value);
        await client.query(
          'UPDATE homepage_config SET config_value = $1, updated_at = CURRENT_TIMESTAMP WHERE config_key = $2 AND is_active = true',
          [stringValue, key]
        );
      }
    }
    
    await client.query('COMMIT');
    return true;
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Erreur lors de la mise à jour des configurations:', error);
    return false;
  } finally {
    client.release();
  }
}

/**
 * Récupère une configuration spécifique par sa clé
 * @param configKey - Clé de la configuration
 * @returns Promise<HomepageConfigItem | null> - Configuration trouvée ou null
 */
export async function getHomepageConfigByKey(configKey: string): Promise<HomepageConfigItem | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM homepage_config WHERE config_key = $1 AND is_active = true',
      [configKey]
    );
    return result.rows[0] || null;
  } finally {
    client.release();
  }
}

/**
 * Récupère les réservations dans une plage de dates pour calculer les disponibilités
 * @param startDate - Date de début (format YYYY-MM-DD)
 * @param endDate - Date de fin (format YYYY-MM-DD)
 * @param roomName - Nom de la salle (optionnel)
 * @returns Promise<Reservation[]> - Liste des réservations
 */
export async function getReservationsByDateRange(
  startDate: string, 
  endDate: string, 
  roomName?: string
): Promise<Reservation[]> {
  const client = await getClient();
  try {
    let query = `
      SELECT * FROM reservations 
      WHERE date >= $1 AND date <= $2 
      AND status IN ('pending', 'confirmed')
    `;
    const params: any[] = [startDate, endDate];
    
    if (roomName) {
      query += ' AND room_name = $3';
      params.push(roomName);
    }
    
    query += ' ORDER BY date, time';
    
    const result = await client.query(query, params);
    return result.rows;
  } finally {
    client.release();
  }
}

// ===== FONCTIONS POUR LA GESTION DES PAGES LÉGALES =====

/**
 * Récupère toutes les pages légales
 * @returns Promise<LegalPage[]> - Liste de toutes les pages légales
 */
export async function getAllLegalPages(): Promise<LegalPage[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM legal_pages ORDER BY page_type'
    );
    return result.rows.map(row => ({
      ...row,
      keywords: row.keywords || []
    }));
  } finally {
    client.release();
  }
}

/**
 * Récupère une page légale par son type
 * @param pageType - Type de page légale (cgv, privacy, legal, cookies)
 * @returns Promise<LegalPage | null> - Page légale trouvée ou null
 */
export async function getLegalPageByType(pageType: string): Promise<LegalPage | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM legal_pages WHERE page_type = $1 AND is_published = true',
      [pageType]
    );
    if (result.rows.length === 0) return null;
    const row = result.rows[0];
    return {
      ...row,
      keywords: row.keywords || []
    };
  } finally {
    client.release();
  }
}

/**
 * Récupère une page légale par son ID
 * @param id - ID de la page légale
 * @returns Promise<LegalPage | null> - Page légale trouvée ou null
 */
export async function getLegalPageById(id: string): Promise<LegalPage | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM legal_pages WHERE id = $1',
      [id]
    );
    if (result.rows.length === 0) return null;
    const row = result.rows[0];
    return {
      ...row,
      keywords: row.keywords || []
    };
  } finally {
    client.release();
  }
}

/**
 * Met à jour une page légale
 * @param id - ID de la page légale
 * @param updates - Données à mettre à jour
 * @param lastUpdatedBy - Nom de l'administrateur qui effectue la modification
 * @returns Promise<boolean> - Succès de l'opération
 */
export async function updateLegalPage(
  id: string, 
  updates: Partial<LegalPage>,
  lastUpdatedBy?: string
): Promise<boolean> {
  const client = await getClient();
  try {
    const fields = [];
    const values = [];
    let paramCount = 1;

    // Construction dynamique de la requête
    for (const [key, value] of Object.entries(updates)) {
      if (value !== undefined && key !== 'id' && key !== 'created_at') {
        fields.push(`${key} = $${paramCount}`);
        values.push(value);
        paramCount++;
      }
    }

    // Ajout du champ last_updated_by si fourni
    if (lastUpdatedBy) {
      fields.push(`last_updated_by = $${paramCount}`);
      values.push(lastUpdatedBy);
      paramCount++;
    }

    if (fields.length === 0) return false;

    values.push(id);
    const query = `UPDATE legal_pages SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP WHERE id = $${paramCount}`;
    
    const result = await client.query(query, values);
    return (result.rowCount ?? 0) > 0;
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la page légale:', error);
    return false;
  } finally {
    client.release();
  }
}

/**
 * Crée une nouvelle page légale
 * @param pageData - Données de la page légale
 * @param lastUpdatedBy - Nom de l'administrateur qui crée la page
 * @returns Promise<LegalPage | null> - Page créée ou null en cas d'erreur
 */
export async function createLegalPage(
  pageData: Omit<LegalPage, 'id' | 'created_at' | 'updated_at'>,
  lastUpdatedBy?: string
): Promise<LegalPage | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      `INSERT INTO legal_pages (
        page_type, title, content, meta_description, seo_title, 
        keywords, is_published, last_updated_by
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) 
      RETURNING *`,
      [
        pageData.page_type,
        pageData.title,
        pageData.content,
        pageData.meta_description,
        pageData.seo_title,
        pageData.keywords || [],
        pageData.is_published,
        lastUpdatedBy
      ]
    );
    
    const row = result.rows[0];
    return {
      ...row,
      keywords: row.keywords || []
    };
  } catch (error) {
    console.error('Erreur lors de la création de la page légale:', error);
    return null;
  } finally {
    client.release();
  }
}

/**
 * Supprime une page légale
 * @param id - ID de la page légale
 * @returns Promise<boolean> - Succès de l'opération
 */
export async function deleteLegalPage(id: string): Promise<boolean> {
  const client = await getClient();
  try {
    const result = await client.query(
      'DELETE FROM legal_pages WHERE id = $1',
      [id]
    );
    return (result.rowCount ?? 0) > 0;
  } catch (error) {
    console.error('Erreur lors de la suppression de la page légale:', error);
    return false;
  } finally {
    client.release();
  }
}

/**
 * Met à jour le statut de publication d'une page légale
 * @param pageType - Type de la page légale (cgv, privacy, legal, cookies)
 * @param isPublished - Statut de publication
 * @returns Promise<LegalPage | null> - Page légale mise à jour ou null si non trouvée
 */
export async function updateLegalPageStatus(pageType: string, isPublished: boolean): Promise<LegalPage | null> {
  const client = await getClient();
  try {
    const result = await client.query(
      `UPDATE legal_pages
       SET is_published = $1, updated_at = NOW()
       WHERE page_type = $2
       RETURNING *`,
      [isPublished, pageType]
    );

    if (result.rows.length === 0) {
      return null;
    }

    return {
      ...result.rows[0],
      keywords: result.rows[0].keywords || []
    };
  } catch (error) {
    console.error('Erreur lors de la mise à jour du statut de la page légale:', error);
    return null;
  } finally {
    client.release();
  }
}

/**
 * Récupère les pages légales publiées pour l'affichage public
 * @returns Promise<LegalPage[]> - Liste des pages légales publiées
 */
export async function getPublishedLegalPages(): Promise<LegalPage[]> {
  const client = await getClient();
  try {
    const result = await client.query(
      'SELECT * FROM legal_pages WHERE is_published = true ORDER BY page_type'
    );
    return result.rows.map(row => ({
      ...row,
      keywords: row.keywords || []
    }));
  } finally {
    client.release();
  }
}
