class ApiEndpoints {
  ApiEndpoints._();

  static const loginBaseUrl =
      'https://old-sourcespot.lucrumerp.com/api/method/lucrum_stock_take_app.api.';

  static const baseUrl =
      'https://old-sourcespot.lucrumerp.com/api/method/lucrum_stock_take_app.api.app_api.';

  // Auth
  static const login = 'auth.login_and_generate_keys';

  // Tasks
  static const getTaskDetails = 'get_task_details';

  // Check-in
  static const checkin = 'checkin.perform_checkin';

  // Stock Request
  static const getMaterialTransferItems = 'get_material_transfer_items';
  static const getAllItems = 'get_all_items';
  static const createStockRequest = 'create_stock_request';

  // Stock Take
  static const createStockTake = 'create_stock_take';
}
