import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _repository;

  CustomerBloc({required CustomerRepository repository})
      : _repository = repository,
        super(CustomerInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<AddCustomerEvent>(_onAddCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
    on<SearchCustomersEvent>(_onSearchCustomers);
  }

  void _onLoadCustomers(LoadCustomersEvent event, Emitter<CustomerState> emit) {
    emit(CustomerLoading());
    try {
      final customers = _repository.getAllCustomers();
      // Sort by updated descending as default
      customers.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      emit(CustomerLoaded(customers: customers, filteredCustomers: customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onAddCustomer(AddCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      await _repository.addCustomer(event.customer);
      add(LoadCustomersEvent());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(UpdateCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      await _repository.updateCustomer(event.customer);
      add(LoadCustomersEvent());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(DeleteCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      await _repository.deleteCustomer(event.customerId);
      add(LoadCustomersEvent());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  void _onSearchCustomers(SearchCustomersEvent event, Emitter<CustomerState> emit) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(currentState.copyWith(filteredCustomers: currentState.customers, searchQuery: ''));
        return;
      }

      final filtered = currentState.customers.where((customer) {
        final nameMatches = customer.name.toLowerCase().contains(query);
        final phoneMatches = customer.mobileNumber?.toLowerCase().contains(query) ?? false;
        return nameMatches || phoneMatches;
      }).toList();

      emit(currentState.copyWith(filteredCustomers: filtered, searchQuery: query));
    }
  }
}
