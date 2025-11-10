'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { Plus, Edit, Trash2, Eye, EyeOff, Save, X, Loader2, Upload, Image } from 'lucide-react';
import type { Room } from '@/lib/database';
import RoomImage from '@/components/RoomImage';

const normalizeStringArray = (value: unknown): string[] => {
  if (Array.isArray(value)) {
    return value
      .map(item => (typeof item === 'string' ? item : String(item ?? '')).trim())
      .filter(Boolean);
  }

  if (typeof value === 'string') {
    const trimmed = value.trim();
    if (!trimmed) return [];

    const looksLikeJsonArray =
      (trimmed.startsWith('[') && trimmed.endsWith(']')) ||
      (trimmed.startsWith('{') && trimmed.endsWith('}'));

    if (looksLikeJsonArray) {
      try {
        const canonical = trimmed.startsWith('{')
          ? `[${trimmed.slice(1, -1)}]`
          : trimmed;
        const parsed = JSON.parse(canonical);
        if (Array.isArray(parsed)) {
          return parsed
            .map(item => (typeof item === 'string' ? item : String(item ?? '')).trim())
            .filter(Boolean);
        }
      } catch {
        // Ignore parsing failures and fallback to comma split
      }
    }

    return trimmed
      .split(',')
      .map(item => item.trim())
      .filter(Boolean);
  }

  if (value == null) {
    return [];
  }

  const stringified = String(value).trim();
  return stringified ? [stringified] : [];
};

export default function AdminRoomsPage() {
  const { isAuthenticated, loading: authLoading, requireAuth } = useAuth();
  const [rooms, setRooms] = useState<Room[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [editingRoom, setEditingRoom] = useState<Room | null>(null);
  const [showOnlyActive, setShowOnlyActive] = useState(false);
  const [formData, setFormData] = useState<Partial<Room>>({
    name: '',
    description: '',
    duration: 30,
    price: 0,
    max_people: 4,
    objects_to_destroy: [],
    included: [],
    image_url: '',
    is_active: true
  });
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [uploadingImage, setUploadingImage] = useState(false);



  // Charger les salles
  const loadRooms = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/admin/rooms');
      const result = await response.json();
      
      if (result.success) {
        setRooms(result.data);
      } else {
        setError(result.error);
      }
    } catch (err) {
      setError('Erreur lors du chargement des salles');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    requireAuth();
    if (isAuthenticated) {
      loadRooms();
    }
  }, [isAuthenticated, requireAuth]);

  // Réinitialiser le formulaire
  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      duration: 30,
      price: 0,
      max_people: 4,
      objects_to_destroy: [],
      included: [],
      image_url: '',
      is_active: true
    });
    setImagePreview(null);
    setEditingRoom(null);
    setShowForm(false);
  };

  // Gérer l'upload d'image
  const handleImageUpload = async (file: File) => {
    try {
      setUploadingImage(true);
      const formData = new FormData();
      formData.append('image', file);

      const response = await fetch('/api/admin/upload', {
        method: 'POST',
        body: formData
      });

      const result = await response.json();

      if (result.success) {
        setFormData(prev => ({ ...prev, image_url: result.data.image_url }));
        setImagePreview(result.data.image_url);
      } else {
        setError(result.error);
      }
    } catch (err) {
      setError('Erreur lors de l\'upload de l\'image');
    } finally {
      setUploadingImage(false);
    }
  };

  // Gérer la sélection de fichier
  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      handleImageUpload(file);
    }
  };

  // Gérer les changements de formulaire
  const handleInputChange = (field: string, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  // Gérer les tableaux (objects_to_destroy, included)
  const handleArrayChange = (field: 'objects_to_destroy' | 'included', value: string) => {
    const items = value.split(',').map(item => item.trim()).filter(item => item);
    // Toujours envoyer un tableau, même vide, pour que l'API le traite correctement
    setFormData(prev => ({ ...prev, [field]: items }));
  };

  // Créer une nouvelle salle
  const handleCreate = async () => {
    try {
      const response = await fetch('/api/admin/rooms', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });

      const result = await response.json();
      
      if (result.success) {
        await loadRooms();
        resetForm();
      } else {
        setError(result.error);
      }
    } catch (err) {
      setError('Erreur lors de la création de la salle');
    }
  };

  // Mettre à jour une salle
  const handleUpdate = async () => {
    if (!editingRoom?.id) return;

    try {
      const response = await fetch(`/api/admin/rooms/${editingRoom.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });

      const result = await response.json();
      
      if (result.success) {
        await loadRooms();
        resetForm();
      } else {
        setError(result.error);
      }
    } catch (err) {
      setError('Erreur lors de la mise à jour de la salle');
    }
  };

  // Supprimer une salle
  const handleDelete = async (id: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette salle ?')) return;

    try {
      const response = await fetch(`/api/admin/rooms/${id}`, {
        method: 'DELETE'
      });

      const result = await response.json();
      
      if (result.success) {
        await loadRooms();
      } else {
        setError(result.error);
      }
    } catch (err) {
      setError('Erreur lors de la suppression de la salle');
    }
  };

  // Basculer le statut d'une salle
  const handleToggleStatus = async (id: string) => {
    try {
      const response = await fetch(`/api/admin/rooms/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'toggle' })
      });

      const result = await response.json();
      
      if (result.success) {
        await loadRooms();
      } else {
        setError(result.error);
      }
    } catch (err) {
      setError('Erreur lors du changement de statut');
    }
  };

  // Éditer une salle
  const handleEdit = (room: Room) => {
    setEditingRoom(room);
    setFormData({
      name: room.name,
      description: room.description,
      duration: room.duration,
      price: room.price,
      max_people: room.max_people,
      objects_to_destroy: room.objects_to_destroy,
      included: room.included,
      image_url: room.image_url || '',
      is_active: room.is_active
    });
    setImagePreview(room.image_url || null);
    setShowForm(true);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-900 text-white p-8">
        <div className="flex items-center justify-center h-64">
          <Loader2 className="w-8 h-8 animate-spin" />
          <span className="ml-2">Chargement des salles...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold text-kaki-400">Gestion des Salles</h1>
            <p className="text-gray-400 mt-2">Créez et gérez les salles de défoulement</p>
          </div>
          <div className="flex items-center space-x-4">
            <a
              href="/admin"
              className="inline-flex items-center px-4 py-2 border border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-300 bg-gray-700 hover:bg-gray-600 transition-colors"
            >
              ← Retour au dashboard
            </a>
            <button
              onClick={() => setShowForm(true)}
              className="bg-kaki-600 hover:bg-kaki-700 text-white px-4 py-2 rounded-lg flex items-center"
            >
              <Plus className="w-4 h-4 mr-2" />
              Nouvelle Salle
            </button>
          </div>
        </div>

        {/* Messages d'erreur */}
        {error && (
          <div className="bg-red-900 border border-red-700 text-red-200 px-4 py-3 rounded-lg mb-6">
            {error}
            <button
              onClick={() => setError(null)}
              className="float-right text-red-400 hover:text-red-200"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        )}

        {/* Formulaire */}
        {showForm && (
          <div className="bg-gray-800 border border-gray-700 rounded-lg p-6 mb-8">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-xl font-semibold">
                {editingRoom ? 'Modifier la Salle' : 'Nouvelle Salle'}
              </h2>
              <button
                onClick={resetForm}
                className="text-gray-400 hover:text-white"
              >
                <X className="w-6 h-6" />
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Informations de base */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Nom de la salle</label>
                  <input
                    type="text"
                    value={formData.name || ''}
                    onChange={(e) => handleInputChange('name', e.target.value)}
                    className="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 text-white"
                    placeholder="Ex: Salle Douce"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">Description</label>
                  <input
                    type="text"
                    value={formData.description || ''}
                    onChange={(e) => handleInputChange('description', e.target.value)}
                    className="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 text-white"
                    placeholder="Ex: Défoulement Soft"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Durée (minutes)</label>
                    <input
                      type="number"
                      value={formData.duration || 30}
                      onChange={(e) => handleInputChange('duration', parseInt(e.target.value))}
                      className="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 text-white"
                      min="1"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-2">Prix (€)</label>
                    <input
                      type="number"
                      value={Math.round(formData.price || 0)}
                      onChange={(e) => handleInputChange('price', parseInt(e.target.value))}
                      className="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 text-white"
                      min="0"
                      step="1"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">Nombre max de personnes</label>
                  <input
                    type="number"
                    value={formData.max_people || 4}
                    onChange={(e) => handleInputChange('max_people', parseInt(e.target.value))}
                    className="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 text-white"
                    min="1"
                  />
                </div>
              </div>

              {/* Description et détails */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Image de la salle</label>
                  <div className="space-y-3">
                    {/* Prévisualisation de l'image */}
                    {(imagePreview || formData.image_url) && (
                      <div className="relative w-full h-32">
                        <RoomImage
                          src={imagePreview || formData.image_url || ''}
                          alt="Aperçu de la salle"
                          className="w-full h-full rounded-lg border border-gray-600"
                          quality={85}
                        />
                        <button
                          type="button"
                          onClick={() => {
                            setImagePreview(null);
                            setFormData(prev => ({ ...prev, image_url: '' }));
                          }}
                          className="absolute top-2 right-2 bg-red-600 hover:bg-red-700 text-white p-1 rounded-full"
                        >
                          <X className="w-3 h-3" />
                        </button>
                      </div>
                    )}
                    
                    {/* Zone d'upload */}
                    <div className="border-2 border-dashed border-gray-600 rounded-lg p-4 text-center hover:border-kaki-500 transition-colors">
                      <input
                        type="file"
                        accept="image/*"
                        onChange={handleFileSelect}
                        className="hidden"
                        id="image-upload"
                        disabled={uploadingImage}
                      />
                      <label
                        htmlFor="image-upload"
                        className="cursor-pointer flex flex-col items-center space-y-2"
                      >
                        {uploadingImage ? (
                          <Loader2 className="w-8 h-8 animate-spin text-kaki-400" />
                        ) : (
                          <Upload className="w-8 h-8 text-gray-400" />
                        )}
                        <span className="text-sm text-gray-400">
                          {uploadingImage ? 'Upload en cours...' : 'Cliquez pour sélectionner une image'}
                        </span>
                        <span className="text-xs text-gray-500">
                          JPG, PNG, GIF (max 5MB)
                        </span>
                      </label>
                    </div>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">Description détaillée</label>
                  <textarea
                    value={formData.description || ''}
                    onChange={(e) => handleInputChange('description', e.target.value)}
                    className="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 text-white h-20"
                    placeholder="Description de la salle..."
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">Objets à détruire (séparés par des virgules)</label>
                  <input
                    type="text"
                    value={(formData.objects_to_destroy || []).join(', ')}
                    onChange={(e) => handleArrayChange('objects_to_destroy', e.target.value)}
                    className="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 text-white"
                    placeholder="Ex: vaisselle, verres, assiettes"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">Inclus (séparés par des virgules)</label>
                  <input
                    type="text"
                    value={(formData.included || []).join(', ')}
                    onChange={(e) => handleArrayChange('included', e.target.value)}
                    className="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 text-white"
                    placeholder="Ex: équipement, protection, encadrement"
                  />
                </div>

                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="is_active"
                    checked={formData.is_active || false}
                    onChange={(e) => handleInputChange('is_active', e.target.checked)}
                    className="w-4 h-4 text-kaki-600 bg-gray-700 border-gray-600 rounded"
                  />
                  <label htmlFor="is_active" className="ml-2 text-sm">
                    Salle active
                  </label>
                </div>
              </div>
            </div>

            {/* Boutons d'action */}
            <div className="flex justify-end space-x-4 mt-6">
              <button
                onClick={resetForm}
                className="px-4 py-2 border border-gray-600 text-gray-300 rounded-lg hover:bg-gray-700"
              >
                Annuler
              </button>
              <button
                onClick={editingRoom ? handleUpdate : handleCreate}
                className="bg-kaki-600 hover:bg-kaki-700 text-white px-4 py-2 rounded-lg flex items-center"
              >
                <Save className="w-4 h-4 mr-2" />
                {editingRoom ? 'Mettre à jour' : 'Créer'}
              </button>
            </div>
          </div>
        )}

        {/* Filtres et statistiques */}
        <div className="mb-6 flex justify-between items-center">
          <div className="flex items-center space-x-4">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={showOnlyActive}
                onChange={(e) => setShowOnlyActive(e.target.checked)}
                className="w-4 h-4 text-kaki-600 bg-gray-700 border-gray-600 rounded"
              />
              <span className="ml-2 text-sm text-gray-300">Afficher seulement les salles actives</span>
            </label>
          </div>
          <div className="text-sm text-gray-400">
            {rooms.filter(room => !showOnlyActive || room.is_active).length} salles affichées
          </div>
        </div>

        {/* Liste des salles */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {rooms
            .filter(room => !showOnlyActive || room.is_active)
            .map((room) => (
            <div
              key={room.id}
              className={`bg-gray-800 border rounded-lg overflow-hidden ${
                room.is_active ? 'border-kaki-600' : 'border-gray-600 opacity-75'
              }`}
            >
              {/* Image de la salle */}
              {room.image_url && (
                <div className="relative h-48 bg-gray-700">
                  <RoomImage
                    src={room.image_url}
                    alt={`Image de la salle ${room.name}`}
                    className="w-full h-full"
                    quality={85}
                  />
                  <div className="absolute inset-0 bg-black bg-opacity-20"></div>
                </div>
              )}

              <div className="p-6">
                {/* Header de la carte */}
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h3 className={`text-lg font-semibold ${room.is_active ? 'text-kaki-400' : 'text-gray-500'}`}>
                    {room.name}
                  </h3>
                  <p className="text-sm text-gray-400">{room.description}</p>
                </div>
                <div className="flex space-x-2">
                  <button
                    onClick={() => handleToggleStatus(room.id)}
                    className={`p-2 rounded-lg ${
                      room.is_active
                        ? 'bg-green-900 text-green-400 hover:bg-green-800'
                        : 'bg-gray-700 text-gray-400 hover:bg-gray-600'
                    }`}
                    title={room.is_active ? 'Désactiver' : 'Activer'}
                  >
                    {room.is_active ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}
                  </button>
                  <button
                    onClick={() => handleEdit(room)}
                    className="p-2 bg-kaki-900 text-kaki-400 rounded-lg hover:bg-kaki-800"
                    title="Modifier"
                  >
                    <Edit className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(room.id)}
                    className="p-2 bg-red-900 text-red-400 rounded-lg hover:bg-red-800"
                    title="Supprimer"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {/* Informations de la salle */}
              <div className="space-y-3">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Durée:</span>
                  <span className="text-white">{room.duration} min</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Prix:</span>
                  <span className="text-white font-semibold">{Math.round(room.price)}€</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Max personnes:</span>
                  <span className="text-white">{room.max_people}</span>
                </div>
                <div className="text-sm">
                  <span className="text-gray-400">Description:</span>
                  <p className="text-white mt-1 line-clamp-2">{room.description}</p>
                </div>
              </div>

              {/* Statut */}
              <div className="mt-4 pt-4 border-t border-gray-700">
                <div className="flex justify-between items-center">
                  <span
                    className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${
                      room.is_active
                        ? 'bg-green-900 text-green-300'
                        : 'bg-red-900 text-red-300'
                    }`}
                  >
                    {room.is_active ? '✓ Active' : '✗ Inactive'}
                  </span>
                  <button
                    onClick={() => handleToggleStatus(room.id)}
                    className={`text-xs px-2 py-1 rounded ${
                      room.is_active
                        ? 'bg-yellow-900 text-yellow-300 hover:bg-yellow-800'
                        : 'bg-green-900 text-green-300 hover:bg-green-800'
                    }`}
                  >
                    {room.is_active ? 'Désactiver' : 'Activer'}
                  </button>
                </div>
              </div>
            </div>
          </div>
          ))}
        </div>

        {/* Message si aucune salle */}
        {rooms.length === 0 && !loading && (
          <div className="text-center py-12">
            <p className="text-gray-400 text-lg">Aucune salle créée</p>
            <button
              onClick={() => setShowForm(true)}
              className="mt-4 bg-kaki-600 hover:bg-kaki-700 text-white px-6 py-2 rounded-lg"
            >
              Créer la première salle
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
