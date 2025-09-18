import { NextRequest, NextResponse } from 'next/server';
import fs from 'fs/promises';
import path from 'path';

export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get('image') as File;

    if (!file) {
      return NextResponse.json(
        { success: false, error: 'Aucune image fournie' },
        { status: 400 }
      );
    }

    // Vérifier le type de fichier
    if (!file.type.startsWith('image/')) {
      return NextResponse.json(
        { success: false, error: 'Le fichier doit être une image' },
        { status: 400 }
      );
    }

    // Vérifier la taille (max 5MB)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
      return NextResponse.json(
        { success: false, error: 'L\'image ne doit pas dépasser 5MB' },
        { status: 400 }
      );
    }

    // Enregistrer le fichier sur le disque et retourner une URL courte
    const uploadsBaseDir = process.env.UPLOAD_DIR || path.join(process.cwd(), 'public', 'uploads');
    const roomsDir = path.join(uploadsBaseDir, 'rooms');
    await fs.mkdir(roomsDir, { recursive: true });

    const originalName = file.name || 'image';
    const extFromName = path.extname(originalName);
    const extFromType = file.type?.split('/')[1] ? `.${file.type.split('/')[1]}` : '';
    const ext = (extFromName || extFromType || '.jpg').toLowerCase();

    const safeName = `${Date.now()}-${Math.random().toString(36).slice(2,8)}${ext}`;
    const targetPath = path.join(roomsDir, safeName);

    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);
    await fs.writeFile(targetPath, buffer);

    // Construire l'URL publique (servie par Next statiquement)
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
    console.error('Erreur lors de l\'upload de l\'image:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de l\'upload de l\'image' },
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
