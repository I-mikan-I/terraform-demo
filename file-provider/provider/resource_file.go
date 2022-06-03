package provider

import (
	"context"
	"github.com/hashicorp/go-uuid"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"os"
)

func resourceFile() *schema.Resource {
	return &schema.Resource{
		CreateContext: resourceFileCreate,
		ReadContext:   resourceFileRead,
		UpdateContext: resourceFileUpdate,
		DeleteContext: resourceFileDelete,
		Schema: map[string]*schema.Schema{
			"path": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},
			"data": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
		},
	}
}

func resourceFileCreate(ctx context.Context, d *schema.ResourceData, m interface{}) (diags diag.Diagnostics) {
	path := d.Get("path").(string)
	data := d.Get("data").(string)
	err := os.WriteFile(path, []byte(data), 0777)
	if err != nil {
		diags = diag.FromErr(err)
	}
	id, _ := uuid.GenerateUUID()
	d.SetId(id)
	resourceFileRead(ctx, d, m)
	return
}

func resourceFileRead(ctx context.Context, d *schema.ResourceData, m interface{}) (diags diag.Diagnostics) {
	path := d.Get("path").(string)
	data, err := os.ReadFile(path)
	if err != nil {
		diags = diag.FromErr(err)
	}
	content := string(data)
	_ = d.Set("path", path)
	_ = d.Set("data", content)
	return
}

func resourceFileUpdate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	newData := d.Get("data").(string)
	if d.HasChange("path") {
		return diag.Errorf("Path requires delete and create")
	}
	path := d.Get("path").(string)
	err := os.WriteFile(path, []byte(newData), 0777)
	if err != nil {
		return diag.FromErr(err)
	}
	return nil
}

func resourceFileDelete(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	// Warning or errors can be collected in a slice type
	path := d.Get("path").(string)
	err := os.Remove(path)
	if err != nil {
		return diag.FromErr(err)
	}
	return nil
}
