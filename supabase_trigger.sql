CREATE OR REPLACE FUNCTION notify_lineart() 
RETURNS trigger AS $$
DECLARE payload JSON;
BEGIN
  payload = json_build_object('id', NEW.id, 'url', NEW.original_url);
  PERFORM http_post('https://your-deployed-api.com/lineart', payload::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_photo_insert
AFTER INSERT ON photos
FOR EACH ROW WHEN (NEW.status = 'pending')
EXECUTE PROCEDURE notify_lineart();
