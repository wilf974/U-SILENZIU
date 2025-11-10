import { NextRequest, NextResponse } from 'next/server';
import fs from 'fs/promises';
import path from 'path';

export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get('image') as File;

    console.log('[Upload] Fichier reçu:', {
      name: file?.name,
      size: file?.size,
      type: file?.type,
      userAgent: request.headers.get('user-agent')
    });

    if (!file) {
      console.error('[Upload] Erreur: Aucun fichier fourni');
      return NextResponse.json(
        { success: false, error: 'Aucune image fournie' },
        { status: 400 }
      );
    }

    // Vérifier le type de fichier - mais être plus flexible pour Safari/iOS
    // Safari peut envoyer un type MIME vide ou application/octet-stream pour les photos
    const isValidImageType =
      file.type.startsWith('image/') ||
      file.type === 'application/octet-stream' ||
      file.type === '' ||
      file.name?.match(/\.(jpg|jpeg|png|gif|webp|heic|heif)$/i);

    console.log('[Upload] Validation type:', {
      fileType: file.type,
      fileName: file.name,
      isValid: isValidImageType
    });

    if (!isValidImageType) {
      console.error('[Upload] Erreur: Type de fichier invalide', file.type);
      return NextResponse.json(
        { success: false, error: 'Le fichier doit être une image (JPG, PNG, GIF, WebP, HEIC)' },
        { status: 400 }
      );
    }

    // Vérifier la taille (max 5MB)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
      console.error('[Upload] Erreur: Fichier trop volumineux', file.size);
      return NextResponse.json(
        { success: false, error: 'L\'image ne doit pas dépasser 5MB' },
        { status: 400 }
      );
    }

    // Enregistrer le fichier sur le disque et retourner une URL courte
    const uploadsBaseDir = process.env.UPLOAD_DIR || path.join(process.cwd(), 'public', 'uploads');
    const roomsDir = path.join(uploadsBaseDir, 'rooms');

    console.log('[Upload] Chemins:', {
      uploadsBaseDir,
      roomsDir
    });

    await fs.mkdir(roomsDir, { recursive: true });

    const originalName = file.name || 'image';
    const extFromName = path.extname(originalName);
    const extFromType = file.type?.split('/')[1] ? `.${file.type.split('/')[1]}` : '';
    const ext = (extFromName || extFromType || '.jpg').toLowerCase();

    const safeName = `${Date.now()}-${Math.random().toString(36).slice(2,8)}${ext}`;
    const targetPath = path.join(roomsDir, safeName);

    console.log('[Upload] Sauvegarde:', {
      originalName,
      safeName,
      ext,
      targetPath
    });

    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);
    await fs.writeFile(targetPath, buffer);

    console.log('[Upload] Fichier sauvegardé avec succès');

    // Construire l'URL publique (servie par Next statiquement depuis /public)
    const publicUrl = `/uploads/rooms/${safeName}`;

    return NextResponse.json({
      success: true,
      data: {
        image_url: publicUrl,
        filename: safeName,
        size: file.size,
        type: file.type
      },
      message: 'Image uploadée avec succès'
    });

  } catch (error) {
    console.error('[Upload] Erreur lors de l\'upload:', {
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined
    });
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : 'Erreur lors de l\'upload de l\'image'
      },
      { status: 500 }
    );
  }
}

// Gérer les autres méthodes HTTP
export async function GET() {
  return NextResponse.json(
    { message: 'Cette API n\'accepte que les requêtes POST' },
    { status: 405 }
  )
}
