 package com.algaworks.crm.controller;

import java.util.ArrayList;
import java.util.HashMap;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.mercadopago.MercadoPago;
import com.mercadopago.resources.Payment;
import com.mercadopago.resources.Preference;
import com.mercadopago.resources.datastructures.payment.Address;
import com.mercadopago.resources.datastructures.payment.Identification;
import com.mercadopago.resources.datastructures.payment.PayerPhone;
import com.mercadopago.exceptions.MPException;
import com.mercadopago.exceptions.MPConfException;
import com.mercadopago.resources.datastructures.payment.Payer;
import com.mercadopago.resources.datastructures.preference.Item;


@CrossOrigin(maxAge = 3600)
@RestController
@RequestMapping("/transacao_pix")
public class ClienteController {
	
	
	@PostMapping(path = "api/gerar_pix")
	public HashMap<String, Object>  gerarPix(
			@RequestParam String nome,
			@RequestParam String sobrenome,
			@RequestParam String email,
			@RequestParam String cidade,
			@RequestParam String bairro,
			@RequestParam String numero,
			@RequestParam String rua,
			@RequestParam String cep,
			@RequestParam String estado,
			@RequestParam String ddd,
			@RequestParam String celular,
			@RequestParam String cpf,
			@RequestParam String valor) throws MPException, MPConfException{
	        
        MercadoPago.SDK.setAccessToken("INSIRA SEU TOKEN AQUI");

			int numeroR = 0;
			float valorDouble = Float.parseFloat(valor);
			
		if(!numero.isEmpty()) {
			numeroR = Integer.parseInt(numero);
		}
	    
	    Address address = new Address();
	    address.setZipCode(cep);
	    address.setStreetName(rua);
	    address.setStreetNumber(Integer.parseInt(numero));
        address.setCity(cidade);
        address.setNeighborhood(bairro);
        address.setFederalUnit(estado);
        
        
        PayerPhone payerPhone = new PayerPhone();
        payerPhone.setAreaCode(ddd);
        payerPhone.setNumber(celular);

        
        Identification identification = new Identification();
        identification.setType("CPF");
        identification.setNumber(cpf);

        Payment payment = new Payment()
                .setTransactionAmount(Float.parseFloat(valor))
                .setDescription("description")
                .setInstallments(1)
                .setPaymentMethodId("pix")
                .setPayer(new Payer()
                        .setEmail("lanchon216@gmail.com")
                        .setFirstName(nome)
                        .setLastName(sobrenome)
                        .setAddress(address)
                        .setIdentification(identification)
                        
                  );
        System.out.println(payment.getTransactionAmount().toString());
        System.out.println(payment.getDescription().toString());
        System.out.println(payment.getInstallments().toString());
        System.out.println(payment.getPaymentMethodId().toString());
        System.out.println(payment.getPayer().getIdentification().toString());
         payment.save();
         
        
	    HashMap<String, Object> map = new HashMap<>();
		 
	    
	     map.put("idPIX", payment.getId());
		 map.put("status", payment.getStatus());
		 map.put("qr_code",payment.getPointOfInteraction().getTransactionData().getQrCode()); 
		 map.put("total_a_pagar", payment.getTransactionDetails().getTotalPaidAmount());
		 map.put("data_expiracao", payment.getDateOfExpiration());
		 	
	
		return map; 
	}
	
	@PostMapping(path = "api/consulta_pix")
	public String obterChavePix(@RequestParam String idPix) throws MPException, MPConfException{
	    MercadoPago.SDK.setAccessToken("INSIRA SEU TOKEN AQUI");

		Payment payment = new Payment();
		
	    String status =	payment.findById(idPix).getStatus().toString();
	    System.out.println(idPix);
		return status; 
	}
	
	@PostMapping(path = "api/pagar_cartao_de_credito")
	public HashMap<String, Object>  pagar_cartao_de_credito(
			@RequestParam String nome,
			@RequestParam String sobrenome,
			@RequestParam String email,
			@RequestParam String cidade,
			@RequestParam String bairro,
			@RequestParam String numero,
			@RequestParam String rua,
			@RequestParam String cep,
			@RequestParam String estado,
			@RequestParam String ddd,
			@RequestParam String celular,
			@RequestParam String cpf,
			@RequestParam String valor) throws MPException, MPConfException{
	        
        MercadoPago.SDK.setAccessToken("INSIRA SEU TOKEN AQUI");

			int numeroR = 0;
			float valorDouble = Float.parseFloat(valor);
			
		if(!numero.isEmpty()) {
			numeroR = Integer.parseInt(numero);
		}
	    
	    Address address = new Address();
	    address.setZipCode(cep);
	    address.setStreetName(rua);
	    address.setStreetNumber(788);
        address.setCity(cidade);
        address.setNeighborhood(bairro);
        address.setFederalUnit(estado);
        
        
     
        
        PayerPhone payerPhone = new PayerPhone();
        payerPhone.setAreaCode(ddd);
        payerPhone.setNumber(celular);
        
        
         
        Identification identification = new Identification();
        identification.setType("CPF");
        identification.setNumber(cpf);
        
        
         
        Payment payment = new Payment()
                .setTransactionAmount(Float.parseFloat(valor))
                .setDescription("description")
                .setInstallments(1)
                .setPaymentMethodId("pix")
                .setPayer(new Payer()
                        .setEmail("pedrotorini123@gmail.com")
                        .setIdentification(null)
                        .setFirstName(nome)
                        .setLastName(sobrenome)
                        .setAddress(address)
                        .setIdentification(identification)
                        
                  );

         payment.save();
         
         
        
	    HashMap<String, Object> map = new HashMap<>();
		 
		 
	     map.put("idPIX", payment.getId()); //
		 map.put("status", payment.getStatus()); //
		 map.put("qr_code",payment.getPointOfInteraction().getTransactionData().getQrCode()); //
		 map.put("total_a_pagar", payment.getTransactionDetails().getTotalPaidAmount());
		 map.put("data_expiracao", payment.getDateOfExpiration());
		 
		
		return map; 
	}
	
	

	
	/*
	
	@GetMapping("/{id}")
	public String obterChave(@PathVariable String id) {
	
			
		return "fedegozo: " + id; 
	}
	*/
	
	
	
	@PostMapping(path = "api/gerar_preferencia")
	public HashMap<String, Object>  gerar_preferencia(
			
			@RequestParam String nome,
			@RequestParam String sobrenome,
			@RequestParam String email,
			@RequestParam String cidade,
			@RequestParam String bairro,
			@RequestParam String numero,
			@RequestParam String rua,
			@RequestParam String cep,
			@RequestParam String estado,
			@RequestParam String ddd,
			@RequestParam String celular,
			@RequestParam String cpf,
			@RequestParam String valor
			
			
			) throws MPException, MPConfException{
	        
		
		
        MercadoPago.SDK.setAccessToken("INSIRA SEU TOKEN AQUI");

			int numeroR = 0;
			float valorDouble = Float.parseFloat(valor);
			
			
		if(!numero.isEmpty()) {
			numeroR = Integer.parseInt(numero);
		}
	    
		
		 com.mercadopago.resources.datastructures.preference.Address  address = 
				        new com.mercadopago.resources.datastructures.preference.Address();
		 
		
	    address.setZipCode(cep);
	    address.setStreetName(rua);
	    address.setStreetNumber(788);
       
	   // address.setCity("Rio de Janeiro");
       // address.setNeighborhood("Campo Grande");
       // address.setFederalUnit("RJ");
        
        
	    com.mercadopago.resources.datastructures.preference.Phone payerPhone =
	    		         new  com.mercadopago.resources.datastructures.preference.Phone();
        payerPhone.setAreaCode(ddd);
        payerPhone.setNumber(celular);
        
        
         
        com.mercadopago.resources.datastructures.preference.Identification identification = 
        		            new  com.mercadopago.resources.datastructures.preference.Identification();
        
        identification.setType("CPF");
        identification.setNumber(cpf);
        
        
        
        
        com.mercadopago.resources.datastructures.preference.Payer 
        payer = new com.mercadopago.resources.datastructures.preference.Payer();
        
        
        
        Item item = new Item();
        
         item.setTitle("livro");
         item.setId(celular);
         item.setQuantity(1);
         item.setUnitPrice(valorDouble);
        
         payer.setAddress(address);
         payer.setIdentification(identification);
         payer.setEmail("pedrotorini123@gmail.com");
         payer.setName(nome);
         payer.setPhone(payerPhone);
         
         
      //  List<> 
        Preference preference = new Preference();
        
        
        ArrayList<com.mercadopago.resources.datastructures.preference.Item> 
                 listaItems = new ArrayList<com.mercadopago.resources.datastructures.preference.Item>() ;
        
     
        listaItems.add(item);
        preference.setItems(listaItems);
        preference.setPayer(payer);
        
        
      
      
      //  preference.getPaymentMethods().setExcludedPaymentMethods();
        	
         
		preference.save();
         
        
	    HashMap<String, Object> map = new HashMap<>();
		 
		 
		 
	     map.put("id", preference.getId()); //
		//map.put("payment methods",preference.getPaymentMethods() ); //
	//	 map.put("qr_code",payment.getPointOfInteraction().getTransactionData().getQrCode()); //
	//	 map.put("total_a_pagar", payment.getTransactionDetails().getTotalPaidAmount());
	//	 map.put("data_expiracao", payment.getDateOfExpiration());
		 
		

	
		return map; 
	}
	
	

	
	
}
