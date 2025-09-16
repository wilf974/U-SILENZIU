import { NextRequest, NextResponse } from 'next/server';

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

    // Convertir l'image en base64
    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);
    const base64 = buffer.toString('base64');
    const mimeType = file.type;
    const dataUrl = `data:${mimeType};base64,${base64}`;

    return NextResponse.json({
      success: true,
      data: {
        image_url: dataUrl,
        filename: file.name,
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
