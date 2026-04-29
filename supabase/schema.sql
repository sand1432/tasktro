-- ============================================================
-- FIXLY AI - SUPABASE DATABASE SCHEMA
-- Complete production-ready schema with RLS policies
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================
-- USERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL DEFAULT '',
  phone TEXT,
  avatar_url TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  is_verified BOOLEAN DEFAULT FALSE,
  preferences JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================================
-- PROVIDERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.providers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  description TEXT,
  services TEXT[] DEFAULT '{}',
  avatar_url TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  rating DOUBLE PRECISION DEFAULT 0.0,
  total_reviews INTEGER DEFAULT 0,
  total_jobs INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  is_available BOOLEAN DEFAULT TRUE,
  response_time_minutes INTEGER DEFAULT 30,
  service_radius_km DOUBLE PRECISION DEFAULT 25.0,
  hourly_rate DOUBLE PRECISION,
  certifications TEXT[] DEFAULT '{}',
  work_photos TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.providers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view providers"
  ON public.providers FOR SELECT
  USING (TRUE);

CREATE POLICY "Providers can update own profile"
  ON public.providers FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Authenticated users can create provider profile"
  ON public.providers FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- SERVICES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  icon_name TEXT,
  base_price_min DOUBLE PRECISION,
  base_price_max DOUBLE PRECISION,
  estimated_duration_minutes INTEGER,
  is_popular BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view services"
  ON public.services FOR SELECT
  USING (TRUE);

-- ============================================================
-- BOOKINGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  provider_id UUID REFERENCES public.providers(id),
  service_id UUID REFERENCES public.services(id),
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'confirmed', 'inProgress', 'completed', 'cancelled', 'disputed')),
  booking_type TEXT NOT NULL DEFAULT 'scheduled'
    CHECK (booking_type IN ('instant', 'scheduled')),
  description TEXT,
  scheduled_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  estimated_cost_min DOUBLE PRECISION,
  estimated_cost_max DOUBLE PRECISION,
  final_cost DOUBLE PRECISION,
  is_locked BOOLEAN DEFAULT FALSE,
  locked_price DOUBLE PRECISION,
  locked_at TIMESTAMPTZ,
  ai_request_id UUID,
  notes TEXT,
  before_images TEXT[] DEFAULT '{}',
  after_images TEXT[] DEFAULT '{}',
  payment_intent_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own bookings"
  ON public.bookings FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Providers can view assigned bookings"
  ON public.bookings FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.providers
      WHERE providers.id = bookings.provider_id
      AND providers.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create bookings"
  ON public.bookings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own bookings"
  ON public.bookings FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Providers can update assigned bookings"
  ON public.bookings FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.providers
      WHERE providers.id = bookings.provider_id
      AND providers.user_id = auth.uid()
    )
  );

-- ============================================================
-- REVIEWS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  provider_id UUID NOT NULL REFERENCES public.providers(id) ON DELETE CASCADE,
  rating DOUBLE PRECISION NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  before_images TEXT[] DEFAULT '{}',
  after_images TEXT[] DEFAULT '{}',
  provider_response TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view reviews"
  ON public.reviews FOR SELECT
  USING (TRUE);

CREATE POLICY "Users can create reviews for own bookings"
  ON public.reviews FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Providers can respond to reviews"
  ON public.reviews FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.providers
      WHERE providers.id = reviews.provider_id
      AND providers.user_id = auth.uid()
    )
  );

-- ============================================================
-- MESSAGES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  sender_id TEXT NOT NULL,
  sender_type TEXT NOT NULL DEFAULT 'user'
    CHECK (sender_type IN ('user', 'provider', 'ai', 'system')),
  message_type TEXT NOT NULL DEFAULT 'text'
    CHECK (message_type IN ('text', 'image', 'video', 'ai', 'system')),
  content TEXT NOT NULL,
  attachment_url TEXT,
  metadata JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Booking participants can view messages"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.bookings
      WHERE bookings.id = messages.booking_id
      AND (
        bookings.user_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM public.providers
          WHERE providers.id = bookings.provider_id
          AND providers.user_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "Booking participants can send messages"
  ON public.messages FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.bookings
      WHERE bookings.id = messages.booking_id
      AND (
        bookings.user_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM public.providers
          WHERE providers.id = bookings.provider_id
          AND providers.user_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "Users can mark messages as read"
  ON public.messages FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.bookings
      WHERE bookings.id = messages.booking_id
      AND bookings.user_id = auth.uid()
    )
  );

-- ============================================================
-- AI REQUESTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ai_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  input_text TEXT NOT NULL,
  input_image_urls TEXT[] DEFAULT '{}',
  problem TEXT,
  causes JSONB DEFAULT '[]',
  estimated_cost_min DOUBLE PRECISION,
  estimated_cost_max DOUBLE PRECISION,
  urgency_level TEXT DEFAULT 'medium',
  confidence_score DOUBLE PRECISION DEFAULT 0.0,
  safety_disclaimer TEXT,
  diy_steps TEXT[] DEFAULT '{}',
  preventive_tips TEXT[] DEFAULT '{}',
  suggested_service_category TEXT,
  is_repeat_issue BOOLEAN DEFAULT FALSE,
  related_request_ids UUID[] DEFAULT '{}',
  raw_response JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.ai_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own AI requests"
  ON public.ai_requests FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create AI requests"
  ON public.ai_requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- SERVICE REPORTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.service_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  provider_id UUID NOT NULL REFERENCES public.providers(id),
  user_id UUID NOT NULL REFERENCES public.users(id),
  summary TEXT NOT NULL,
  work_performed TEXT[] DEFAULT '{}',
  cost_breakdown JSONB DEFAULT '[]',
  total_cost DOUBLE PRECISION DEFAULT 0.0,
  warranty_info TEXT,
  warranty_expires_at TIMESTAMPTZ,
  before_images TEXT[] DEFAULT '{}',
  after_images TEXT[] DEFAULT '{}',
  recommendations TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.service_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Report participants can view reports"
  ON public.service_reports FOR SELECT
  USING (auth.uid() = user_id OR
    EXISTS (
      SELECT 1 FROM public.providers
      WHERE providers.id = service_reports.provider_id
      AND providers.user_id = auth.uid()
    )
  );

CREATE POLICY "Providers can create reports"
  ON public.service_reports FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.providers
      WHERE providers.id = service_reports.provider_id
      AND providers.user_id = auth.uid()
    )
  );

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_providers_location ON public.providers (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_providers_services ON public.providers USING GIN (services);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_provider_id ON public.bookings (provider_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings (status);
CREATE INDEX IF NOT EXISTS idx_messages_booking_id ON public.messages (booking_id);
CREATE INDEX IF NOT EXISTS idx_reviews_provider_id ON public.reviews (provider_id);
CREATE INDEX IF NOT EXISTS idx_ai_requests_user_id ON public.ai_requests (user_id);

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_providers_updated_at
  BEFORE UPDATE ON public.providers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_bookings_updated_at
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Update provider rating on new review
CREATE OR REPLACE FUNCTION update_provider_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.providers
  SET
    rating = (SELECT AVG(rating) FROM public.reviews WHERE provider_id = NEW.provider_id),
    total_reviews = (SELECT COUNT(*) FROM public.reviews WHERE provider_id = NEW.provider_id)
  WHERE id = NEW.provider_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_provider_rating
  AFTER INSERT OR UPDATE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION update_provider_rating();

-- Increment provider total jobs on booking completion
CREATE OR REPLACE FUNCTION update_provider_jobs()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    UPDATE public.providers
    SET total_jobs = total_jobs + 1
    WHERE id = NEW.provider_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_provider_jobs
  AFTER UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION update_provider_jobs();

-- ============================================================
-- SEED DATA: Sample Services
-- ============================================================
INSERT INTO public.services (name, category, description, icon_name, base_price_min, base_price_max, estimated_duration_minutes, is_popular, tags) VALUES
  ('Leak Repair', 'plumbing', 'Fix leaky faucets, pipes, and toilets', 'plumbing', 50, 200, 60, TRUE, ARRAY['leak', 'faucet', 'pipe', 'water']),
  ('Drain Cleaning', 'plumbing', 'Unclog and clean drains', 'plumbing', 75, 300, 90, TRUE, ARRAY['drain', 'clog', 'clean']),
  ('Outlet Installation', 'electrical', 'Install new electrical outlets', 'electrical_services', 60, 250, 60, TRUE, ARRAY['outlet', 'socket', 'plug']),
  ('Wiring Repair', 'electrical', 'Fix faulty wiring and circuits', 'electrical_services', 80, 400, 120, FALSE, ARRAY['wire', 'circuit', 'breaker']),
  ('AC Repair', 'hvac', 'Air conditioning repair and maintenance', 'hvac', 80, 500, 120, TRUE, ARRAY['ac', 'cooling', 'air']),
  ('Heating Repair', 'hvac', 'Furnace and heating system repair', 'hvac', 90, 600, 120, FALSE, ARRAY['heating', 'furnace', 'boiler']),
  ('Deep Cleaning', 'cleaning', 'Full house deep cleaning service', 'cleaning_services', 100, 400, 240, TRUE, ARRAY['deep', 'house', 'full']),
  ('Move Out Cleaning', 'cleaning', 'Post-move cleaning service', 'cleaning_services', 150, 500, 300, FALSE, ARRAY['move', 'apartment', 'vacant']),
  ('Roof Inspection', 'roofing', 'Professional roof inspection', 'roofing', 100, 300, 60, FALSE, ARRAY['roof', 'inspect', 'leak']),
  ('Interior Painting', 'painting', 'Interior wall painting service', 'format_paint', 200, 2000, 480, TRUE, ARRAY['paint', 'wall', 'interior']),
  ('Lock Change', 'locksmith', 'Change or rekey locks', 'lock', 50, 200, 45, TRUE, ARRAY['lock', 'key', 'security']),
  ('Appliance Repair', 'appliance', 'Repair household appliances', 'kitchen', 60, 350, 90, TRUE, ARRAY['appliance', 'washer', 'dryer', 'fridge'])
ON CONFLICT DO NOTHING;

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================
-- Run these via Supabase Dashboard or CLI:
-- supabase storage create profile-images --public
-- supabase storage create service-images --public
-- supabase storage create before-after-images --public
-- supabase storage create chat-attachments
-- supabase storage create video-inspections

-- ============================================================
-- REALTIME
-- ============================================================
-- Enable realtime for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;
